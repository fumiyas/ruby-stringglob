## Ruby StringGlob: Generate a Regexp object from a glob(3) pattern
##       (Port Text::Glob 0.08 from Perl to Ruby)
## Copyright (c) 2002, 2003, 2006, 2007 Richard Clamp.  All Rights Reserved.
## Copyright (c) 2009-2011 SATOH Fumiyasu @ OSS Technology Inc.
##               <http://www.osstech.co.jp/>
##
## License: This module is free software; you can redistribute it and/or
##          modify it under the same terms as Ruby itself
## Date: 2011-06-21, since 2009-07-15

require "stringglob/version"

module StringGlob
  IGNORE_CASE =			1 << 0
  NO_STRICT_LEADING_DOT = 	1 << 1
  NO_STRICT_WILDCARD_SLASH =	1 << 2

  def regexp(glob, opt = 0, code = nil)
    re = regexp_string(glob, opt)
    return Regexp.new("\\A#{re}\\z", nil, code)
  end
  module_function :regexp

  def regexp_string(glob, opt = 0)
    re_str = ''
    in_curlies = 0
    escaping = false
    first_byte = true
    asterisk = false
    strict_leading_dot = (opt & NO_STRICT_LEADING_DOT == 0)
    strict_wildcard_slash = (opt & NO_STRICT_WILDCARD_SLASH == 0)
    glob.scan(/./m) do |glob_c|
      if first_byte
	if strict_leading_dot
	  re_str += '(?=[^\.])' unless glob_c == '.'
	end
	first_byte = false
      end
      if asterisk && glob_c != '*'
	re_str += strict_wildcard_slash ? '[^/]*' : '.*'
	asterisk = false
      end
      if glob_c == '/'
	first_byte = true
      end
      if (glob_c == '.' || glob_c == '(' || glob_c == ')' || glob_c == '|' ||
	  glob_c == '+' || glob_c == '^' || glob_c == '$' || glob_c == '@' || glob_c == '%' )
	re_str += '\\' + glob_c
      elsif glob_c == '*'
	if escaping
	  re_str += '\\*'
	elsif asterisk
	  re_str += '.*'
	  asterisk = false
	else
	  asterisk = true
	end
      elsif glob_c == '?'
	re_str += escaping ? '\\?' :
	  strict_wildcard_slash ? '[^/]' : '.'
      elsif glob_c == '{'
	re_str += escaping ? '\\{' : '('
	in_curlies += 1 unless escaping
      elsif glob_c == '}' && in_curlies > 0
	re_str += escaping ? '}' : ')'
	in_curlies -= 1 unless escaping
      elsif glob_c == ',' && in_curlies > 0
	re_str += escaping ? ',' : '|'
      elsif glob_c == '\\'
	if escaping
	  re_str += '\\\\'
	  escaping = false
	else
	  escaping = true
	end
	next
      else
	## Suppress warning: re_str has `}' without escape
	re_str += '\\' if glob_c == '}'
	re_str += glob_c
	escaping = false
      end
      escaping = false
    end
    if asterisk
      re_str += strict_wildcard_slash ? '[^/]*' : '.*'
    end

    re_str = "(?i:#{re_str})" if (opt & IGNORE_CASE != 0)

    return re_str
  end
  module_function :regexp_string
end

