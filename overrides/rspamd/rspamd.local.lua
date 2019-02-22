local rspamd_regexp = require "rspamd_regexp";
local log = require "rspamd_logger";
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
-- if dest is not on delivered domains and X-SPAM is y
-- we add a flag that will be catched by postfix header_filters routing to
-- redirect outgoing spam to a specific address for further manual processing by sysadmins
local cusourdomains = {
  rspamd_regexp.create_cached('/[a-zA-Z0-9_.+-]+@{{cops_mailer_ourdomains.replace('\\', '')}}/im'),
};
local is_on = rspamd_regexp.create_cached('/^(?:1|y(?:es)?)$/im');
rspamd_config:register_symbol({
  name = 'ADD_X_OUTGOING_SPAM',
  type = 'idempotent',
  callback = function(task)
    local parts = task:get_text_parts();
    local is_domain = false;
    local pr = task:get_principal_recipient();
    local spam_action = task:get_metric_action('default');
    local is_spam = (spam_action ~= 'no action' and action ~= 'greylist')
    for i, pat in ipairs(cusourdomains) do
      if pat:match(pr) then
        is_domain = true;
        break
      end
    end
    -- task:set_milter_reply({add_headers = {
    --   ['X-Cops-OutSpam-isdomain'] = tostring(is_domain),
    --   ['X-Cops-OutSpam-Spam-pr'] = pr,
    -- }});
    if is_spam and not is_domain then
      task:set_milter_reply({add_headers = {['X-Outgoing-Spam'] = '1'}});
    end
  end
});
--
{{cops_mailer_rspamd_lua_custom}}
