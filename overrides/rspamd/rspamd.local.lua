local reconf = config['regexp'];
local group = "custom";
{% if cops_mailer_rspamd_lua_whitelisted %}
local whitelistedsenders = {
    {% for i in cops_mailer_rspamd_lua_whitelisted%}
    "{{i}}",
    {% endfor %}
};
reconf['WHITELIST_CUSTOMERS'] = {
  re = string.format("(%s)", table.concat(whitelistedsenders, ") | (")),
  group = group,
  description = "authorized senders",
  score = -30000.0,
}
{% endif %}
--
reconf['testspam'] = {
  re="/(?:{{cops_mailer_rspamd_testspam_token}})/im{all_header}",
  group = group,
  description = "spamtest",
  score = 15.0,
}
--
{{cops_mailer_rspamd_lua_custom}}
