{{define 'prefix' (lower-snake component.name) ~}}
{{prefix}}_port={{component.port}}
{{prefix}}_user="{{component.username}}"
{{prefix}}_pass="{{component.password}}"
{{prefix}}_machine_type="{{deployment.machine_type}}"
