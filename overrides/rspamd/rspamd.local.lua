local rspamd_regexp = require "rspamd_regexp";
local log = require "rspamd_logger";
local reconf = config['regexp'];
local group = "custom";
local bmevent_re = "/prodid....bluemind..bluemind calendar/im";
local is_bm_event = rspamd_regexp.create_cached(bmevent_re);
--
{% if cops_mailer_rspamd_lua_blacklisted %}
local blacklistedsenders = {
{% for i in cops_mailer_rspamd_lua_blacklisted%}
    "{{i}}",
{% endfor %}
};
reconf['BLACKLISTED_SENDERS'] = {
  re = string.format("(%s)", table.concat(blacklistedsenders, ") | (")),
  group = group,
  description = "not authorized senders",
  score = 30000.0,
}
{% endif %}

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
--
rspamd_config.WHITELIST_BMEVENT = {
  callback = function(task)
    local mh = tostring(task:get_raw_headers());
    local mc = tostring(task:get_content())
    local is_a_bmevent = is_bm_event:match(mh) or is_bm_event:match(mc);
    return is_a_bmevent;
  end,
  group = group,
  description = "authorized bm events outputs2",
  type = 'prefilter',
  score = -40.0,
}
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
local cusourdomainswhitelistdest = {
{% for i in cops_mailer_sentry_dests%}
  rspamd_regexp.create_cached('/{{i}}|/im'),
{% endfor %}
};
local cusourdomainswhitelistexp = {
{% for i in cops_mailer_sentry_dests%}
  rspamd_regexp.create_cached('/{{i}}/im'),
{% endfor %}
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
    local mc = tostring(task:get_content())
    local mh = tostring(task:get_raw_headers())
    local is_a_bmevent = is_bm_event:match(mh) or is_bm_event:match(mc);
    for i, pat in ipairs(cusourdomains) do
      if pat:match(pr) then
        is_domain = true;
        break
      end
    end
    aheaders = {
        ['X-Cops-OutSpam-isdomain'] = tostring(is_domain),
        ['X-Cops-OutSpam-Spam-pr'] = pr,
        ['X-Cops-OutSpam-SpamH'] = is_bm_event:match(mh),
        ['X-Cops-OutSpam-SpamC'] = is_bm_event:match(mc),
    };
    if is_spam and not is_domain and not is_a_bmevent then
      aheaders['X-Outgoing-Spam'] = '1';
    end
    task:set_milter_reply({add_headers = aheaders});
  end
});
--
{{cops_mailer_rspamd_lua_custom}}
