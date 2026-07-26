-- macros/clean_amount.sql
{% macro clean_amount(column_name) %}
    case
        when {{ column_name }} < 0 then null
        else {{ column_name }}
    end
{% endmacro %}