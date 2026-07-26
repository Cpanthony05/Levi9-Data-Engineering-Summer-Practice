-- macros/tests/test_positive_value.sql
{% test positive_value(model, column_name) %}
select *
from {{ model }}
where {{ column_name }} < 0
{% endtest %}