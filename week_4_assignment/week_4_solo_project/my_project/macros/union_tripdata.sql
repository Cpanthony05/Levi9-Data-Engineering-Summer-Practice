-- macros/union_tripdata.sql
{% macro union_tripdata(models) %}
    {% for model in models %}
        select * from {{ ref(model) }}
        {% if not loop.last %}union all{% endif %}
    {% endfor %}
{% endmacro %}