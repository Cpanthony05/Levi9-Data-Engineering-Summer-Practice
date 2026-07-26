# Building a dbt Project From Scratch

This guide walks you through recreating this project step by step. By the end you
will have a working **dbt + DuckDB** project that ingests raw NYC TLC taxi trip
data (green + yellow cabs), cleans it, unions it, enriches it with borough/zone
information, and aggregates it into a monthly fact table, complete with a
reusable macro-based test.

Follow the phases in order. Each phase builds on the previous one, so don't skip
ahead even if a step looks optional.

Throughout this guide, `<your_project_name>` is a placeholder: pick any name
you like (lowercase, underscores only) and use it consistently everywhere you
see the placeholder.

---

## Architecture overview

```
seeds/taxi_zone_lookup.csv ─────────────┐
                                         ▼
data/*.parquet (green/yellow) ──► staging ──► intermediate ──► marts
                                   (clean,      (union +         (aggregate +
                                    rename)      enrich)          surrogate key)
```

| Layer | Folder | Purpose |
|---|---|---|
| Sources | `models/staging/_sources.yml` | Declares the raw parquet files and the zone lookup seed as dbt sources |
| Staging | `models/staging/` | 1:1 with sources, renames columns, cleans bad values |
| Intermediate | `models/intermediate/` | Unions green + yellow trips, joins on pickup/dropoff zones |
| Marts | `models/marts/core/` | Business-facing aggregate: trips per cab type / borough / zone / month |

---

## Phase 0: Prerequisites

You'll need:

- **Python 3.9+** installed and on your PATH
- **pip**
- A terminal (PowerShell, if on Windows)
- Optional but recommended: an IDE (PyCharm/VS Code) and DBeaver/CLI for
  poking at the resulting DuckDB file

Check your Python version:

```powershell
python --version
```

---

## Phase 1: Project skeleton and virtual environment

Create a project folder, set up and activate a Python virtual environment in
it, then install dbt with the DuckDB adapter:

```powershell
pip install dbt-core dbt-duckdb
```

`dbt-duckdb` pulls in `duckdb` itself as a dependency. DuckDB is an embedded,
file-based analytical database, there's no server to stand up, which makes
it perfect for a self-contained class project.

---

## Phase 2: Initialize the dbt project

Run the dbt scaffolding command and answer the prompts (name the project
`<your_project_name>`, pick `duckdb` as the adapter):

```powershell
dbt init <your_project_name>
```

This generates the standard dbt folder layout:

```
<your_project_name>/
├── dbt_project.yml
├── models/
│   └── example/
│       ├── my_first_dbt_model.sql
│       ├── my_second_dbt_model.sql
│       └── schema.yml
├── analyses/
├── macros/
├── seeds/
├── snapshots/
├── tests/
└── README.md
```

`cd` into it for the rest of this guide:

```powershell
cd <your_project_name>
```

### Update `dbt_project.yml`

Open `dbt_project.yml` and confirm/set:

```yaml
name: '<your_project_name>'
version: '1.0.0'
profile: '<your_project_name>'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

clean-targets:
  - "target"
  - "dbt_packages"

models:
  <your_project_name>:
    example:
      +materialized: view
```

We leave the `example` models in place for now (they're a useful sanity check
that dbt is wired up correctly), you'll build the real models alongside them.

---

## Phase 3: Configure your DuckDB profile

dbt looks for connection details in `profiles.yml`, which lives **outside**
the project, in `~/.dbt/profiles.yml` (create the file/folder if it doesn't
exist). Add an entry matching the `profile:` name from `dbt_project.yml`:

```yaml
<your_project_name>:
  outputs:
    dev:
      type: duckdb
      path: dev.duckdb
      threads: 1

    prod:
      type: duckdb
      path: prod.duckdb
      threads: 4

  target: dev
```

- `dev.duckdb` / `prod.duckdb` are just local files that DuckDB creates the
  first time you run dbt: no external database server required.
- `target: dev` tells dbt which output to use by default.

Verify the connection:

```powershell
dbt debug
```

You should see `Connection test: [OK connection ok]`. If dbt can't find your
profile, double check the `profile:` name in `dbt_project.yml` matches the
top-level key in `profiles.yml` exactly.

Sanity-check the whole pipeline before you've written any real models:

```powershell
dbt run
dbt test
```

Both should succeed against the `example` models.

---

## Phase 4: Get the source data

This project models NYC Taxi & Limousine Commission (TLC) trip record data.

1. Create a `data/` folder at the project root.
2. Download **green** and **yellow** taxi trip parquet files from the
   [NYC TLC Trip Record Data page](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)
   for a couple of months, and place them in `data/` using this naming
   convention (the pattern matters, see Phase 5):

   ```
   data/
   ├── green_tripdata_2026-01.parquet
   ├── green_tripdata_2026-02.parquet
   ├── yellow_tripdata_2026-01.parquet
   └── yellow_tripdata_2026-02.parquet
   ```

3. Grab the standard **taxi zone lookup** CSV (also published by the TLC) and
   save it as a dbt **seed**:

   ```
   seeds/taxi_zone_lookup.csv
   ```

   It has this shape:

   ```csv
   "LocationID","Borough","Zone","service_zone"
   1,"EWR","Newark Airport","EWR"
   2,"Queens","Jamaica Bay","Boro Zone"
   3,"Bronx","Allerton/Pelham Gardens","Boro Zone"
   ...
   ```

Load the seed into DuckDB:

```powershell
dbt seed
```

This creates a `taxi_zone_lookup` table in `dev.duckdb`.

> **Why a seed for zone lookup but raw files for trips?** The zone lookup is
> a small, static reference table: a great fit for `dbt seed`. The trip data
> is large and read-only; instead of loading it, we let DuckDB query the
> parquet files directly, which is the next phase.

---

## Phase 5: Declare sources (reading parquet files directly)

Create `models/staging/_sources.yml`. This is where dbt-duckdb's **external
source** feature comes in: setting `meta.external_location` on a source table
makes `{{ source(...) }}` resolve directly to a file glob instead of a table
that must already exist in the warehouse.

```yaml
sources:
  - name: nyc_taxi
    tables:
      - name: green_tripdata
        meta:
          external_location: "data/green_tripdata_2026-*.parquet"
      - name: yellow_tripdata
        meta:
          external_location: "data/yellow_tripdata_2026-*.parquet"
```

When you later reference `{{ source('nyc_taxi', 'green_tripdata') }}` in a
model, dbt-duckdb compiles it straight to `from 'data/green_tripdata_2026-*.parquet'`
, DuckDB reads all matching files as one logical table, no ingestion step
needed. You can confirm this yourself later by inspecting the compiled SQL in
`target/compiled/`.

---

## Phase 6: Staging layer

Staging models are a thin, 1:1 layer over each source: rename cryptic raw
column names into something readable, and fix obviously bad values. Nothing
else: no joins, no aggregation.

### A reusable cleaning macro

Negative fares/tips are bad data. Rather than repeating a `case` expression in
every model, write a macro. Create `macros/clean_amount.sql`:

```sql
-- macros/clean_amount.sql
{% macro clean_amount(column_name) %}
    case
        when {{ column_name }} < 0 then null
        else {{ column_name }}
    end
{% endmacro %}
```

### `models/staging/stg_green_tripdata.sql`

```sql
-- models/staging/stg_green_tripdata.sql
select
    vendorid as vendor_id,
    lpep_pickup_datetime as pickup_datetime,
    lpep_dropoff_datetime as dropoff_datetime,
    pulocationid as pickup_location_id,
    dolocationid as dropoff_location_id,
    passenger_count,
    trip_distance,
    {{ clean_amount('fare_amount') }} as fare_amount,
    {{ clean_amount('tip_amount') }} as tip_amount,
    total_amount,
    'green' as cab_type
from {{ source('nyc_taxi', 'green_tripdata') }}
```

### `models/staging/stg_yellow_tripdata.sql`

Same shape, but yellow cabs name their pickup/dropoff timestamp columns
differently (`tpep_*` instead of `lpep_*`), this is exactly the kind of
inconsistency the staging layer exists to paper over:

```sql
-- models/staging/stg_yellow_tripdata.sql
select
    vendorid as vendor_id,
    tpep_pickup_datetime as pickup_datetime,
    tpep_dropoff_datetime as dropoff_datetime,
    pulocationid as pickup_location_id,
    dolocationid as dropoff_location_id,
    passenger_count,
    trip_distance,
    {{ clean_amount('fare_amount') }} as fare_amount,
    {{ clean_amount('tip_amount') }} as tip_amount,
    total_amount,
    'yellow' as cab_type
from {{ source('nyc_taxi', 'yellow_tripdata') }}
```

### `models/staging/stg_taxi_zone_lookup.sql`

This one sits on top of the **seed**, not a source, note the plain `ref()`:

```sql
-- models/staging/stg_taxi_zone_lookup.sql
select
    locationid as location_id,
    borough,
    zone,
    service_zone
from {{ ref('taxi_zone_lookup') }}
```

Build the staging layer:

```powershell
dbt run --select staging.*
```

---

## Phase 7: A macro that unions models together

We need to stack green and yellow trips into one long list of trips. Instead
of hardcoding `union all` in the model, write a macro that loops over a list
of model names, this makes it trivial to add a third cab type later without
touching the union logic. Create `macros/union_tripdata.sql`:

```sql
-- macros/union_tripdata.sql
{% macro union_tripdata(models) %}
    {% for model in models %}
        select * from {{ ref(model) }}
        {% if not loop.last %}union all{% endif %}
    {% endfor %}
{% endmacro %}
```

`loop.last` is a Jinja/dbt built-in inside `{% for %}` loops: it's `true` on
the final iteration, which is how we avoid a trailing `union all`.

---

## Phase 8: Intermediate layer

### `models/intermediate/int_trips_unioned.sql`

```sql
-- models/intermediate/int_trips_unioned.sql
{{ union_tripdata(['stg_green_tripdata', 'stg_yellow_tripdata']) }}
```

### `models/intermediate/int_trips_enriched.sql`

Join the unioned trips against the zone lookup **twice**: once for pickup,
once for dropoff, to attach human-readable borough/zone names:

```sql
-- models/intermediate/int_trips_enriched.sql
select
    t.*,
    pu.borough as pickup_borough,
    pu.zone as pickup_zone,
    dof.borough as dropoff_borough,
    dof.zone as dropoff_zone
from {{ ref('int_trips_unioned') }} t
left join {{ ref('stg_taxi_zone_lookup') }} pu
    on t.pickup_location_id = pu.location_id
left join {{ ref('stg_taxi_zone_lookup') }} dof
    on t.dropoff_location_id = dof.location_id
```

Build and check:

```powershell
dbt run --select intermediate.*
```

---

## Phase 9: Add the `dbt_utils` package

The final mart needs a stable surrogate key, which we'll generate with
`dbt_utils.generate_surrogate_key` rather than hand-rolling a hash expression.

Create `packages.yml` at the project root:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.1.0", "<2.0.0"]
```

Install it:

```powershell
dbt deps
```

This downloads the package into `dbt_packages/` and writes a
`package-lock.yml` pinning the exact resolved version: don't hand-edit
`package-lock.yml`, it's generated.

---

## Phase 10: Marts layer

`models/marts/core/fct_trips.sql` aggregates enriched trips to a
`cab_type / pickup_borough / pickup_zone / month` grain, and gives every row
a deterministic surrogate key:

```sql
with aggregated as (
    select
        cab_type,
        pickup_borough,
        pickup_zone,
        date_trunc('month', pickup_datetime) as trip_month,
        count(*) as total_trips,
        sum(trip_distance) as total_distance,
        sum(fare_amount) as total_fare,
        sum(tip_amount) as total_tips
    from {{ ref('int_trips_enriched') }}
    group by 1, 2, 3, 4
)

select
    {{ dbt_utils.generate_surrogate_key(['cab_type', 'pickup_borough', 'pickup_zone', 'trip_month']) }} as trip_id,
    *
from aggregated
```

`generate_surrogate_key` hashes the listed columns into a single stable ID,
useful because this table has no natural single-column primary key.

Build it:

```powershell
dbt run --select marts.*
```

---

## Phase 11: A custom generic (reusable) test

dbt ships built-in generic tests (`unique`, `not_null`, `accepted_values`,
`relationships`), but you can also write your own. A **generic test** is a
macro named with the `test` keyword instead of `macro`, living under a
`macros/` subfolder (by convention, `macros/test/` or `macros/tests/`).

Create `macros/test/test_positive_value.sql`:

```sql
-- macros/tests/test_positive_value.sql
{% test positive_value(model, column_name) %}
select *
from {{ model }}
where {{ column_name }} < 0
{% endtest %}
```

A generic test **passes when the query returns zero rows**: here, that means
"no row has a negative value in this column."

Wire it up against a column in a schema file, e.g. add this to
`models/staging/schema.yml`:

```yaml
version: 2

models:
  - name: stg_green_tripdata
    columns:
      - name: fare_amount
        data_tests:
          - positive_value
      - name: tip_amount
        data_tests:
          - positive_value
```

You can apply the same test to `stg_yellow_tripdata`. Because
`clean_amount()` already nulls out negatives, this test should always pass:
it exists as a guardrail in case that macro's logic ever changes.

---

## Phase 12: Standard schema tests

The scaffolded `models/example/schema.yml` shows the built-in pattern for
column-level tests:

```yaml
version: 2

models:
  - name: my_first_dbt_model
    description: "A starter dbt model"
    columns:
      - name: id
        description: "The primary key for this table"
        data_tests:
          - unique
          - not_null

  - name: my_second_dbt_model
    description: "A starter dbt model"
    columns:
      - name: id
        description: "The primary key for this table"
        data_tests:
          - unique
          - not_null
```

As an exercise, add an equivalent schema file for `fct_trips` asserting
`trip_id` is `unique` and `not_null`, that's the column the whole mart's
grain depends on.

---

## Phase 13: Run everything end to end

From the project root, do a full build:

```powershell
dbt deps      # install packages (dbt_utils)
dbt seed      # load seeds/taxi_zone_lookup.csv
dbt run       # build all models in dependency order
dbt test      # run all schema + generic tests
```

Or in one shot:

```powershell
dbt build
```

`dbt build` seeds, runs, and tests everything together, respecting the
dependency graph.

### Explore the results

Open `dev.duckdb` with the DuckDB CLI (`duckdb dev.duckdb`) or a SQL client
and query the models you just built. A few examples to get you started:

Busiest pickup zones overall:

```sql
select
    pickup_borough,
    pickup_zone,
    sum(total_trips) as total_trips
from fct_trips
group by 1, 2
order by total_trips desc
limit 10;
```

Green vs. yellow cab volume and revenue, month over month:

```sql
select
    trip_month,
    cab_type,
    sum(total_trips) as total_trips,
    sum(total_fare) as total_fare,
    sum(total_tips) as total_tips
from fct_trips
group by 1, 2
order by trip_month, cab_type;
```

Average tip as a percentage of fare, by borough: this drops down to the
intermediate model, which still has one row per individual trip:

```sql
select
    pickup_borough,
    round(100 * sum(tip_amount) / nullif(sum(fare_amount), 0), 2) as avg_tip_pct
from int_trips_enriched
group by 1
order by avg_tip_pct desc;
```

Confirm the surrogate key really is unique per row (should return 0 rows):

```sql
select trip_id, count(*)
from fct_trips
group by trip_id
having count(*) > 1;
```

### Generate documentation

```powershell
dbt docs generate
dbt docs serve
```

This opens an interactive lineage graph in your browser, a great way to
visually confirm your DAG matches the architecture diagram at the top of this
guide.

---

## Final project structure

```
<your_project_name>/
├── dbt_project.yml
├── packages.yml
├── package-lock.yml          # generated by `dbt deps`
├── README.md
├── data/
│   ├── green_tripdata_2026-01.parquet
│   ├── green_tripdata_2026-02.parquet
│   ├── yellow_tripdata_2026-01.parquet
│   └── yellow_tripdata_2026-02.parquet
├── seeds/
│   └── taxi_zone_lookup.csv
├── macros/
│   ├── clean_amount.sql
│   ├── union_tripdata.sql
│   └── test/
│       └── test_positive_value.sql
├── models/
│   ├── example/
│   │   ├── my_first_dbt_model.sql
│   │   ├── my_second_dbt_model.sql
│   │   └── schema.yml
│   ├── staging/
│   │   ├── _sources.yml
│   │   ├── stg_green_tripdata.sql
│   │   ├── stg_yellow_tripdata.sql
│   │   └── stg_taxi_zone_lookup.sql
│   ├── intermediate/
│   │   ├── int_trips_unioned.sql
│   │   └── int_trips_enriched.sql
│   └── marts/
│       └── core/
│           └── fct_trips.sql
├── analyses/
├── snapshots/
└── tests/
```

---

## Troubleshooting

- **`dbt debug` fails to find a profile**: check that the `profile:` value in
  `dbt_project.yml` exactly matches a top-level key in `~/.dbt/profiles.yml`.
- **"Catalog Error: Table … does not exist"** on a source: check your
  `external_location` glob pattern actually matches files under `data/`
  (paths in `_sources.yml` are relative to the project root, i.e. where you
  run `dbt` from).
- **`dbt_utils.generate_surrogate_key` not found**: run `dbt deps` before
  `dbt run`; `dbt_packages/` isn't checked into git-worthy state until then.
- **Seed doesn't show up in a model**: seeds need `dbt seed` run at least
  once; `dbt run` alone does not load CSVs.

---

## Stretch goals (optional exercises)

1. Add a third cab type (e.g. `fhv_tripdata`) and confirm `union_tripdata`
   handles it with no changes to its own macro code.
2. Materialize `fct_trips` as a `table` instead of the default `view` and
   compare `dbt run` times.
3. Add a `relationships` test asserting every `pickup_location_id` in staging
   exists in `stg_taxi_zone_lookup`.
4. Remove the `models/example/` folder once you're confident the rest of the
   project runs cleanly without it, and delete its config block from
   `dbt_project.yml`.
