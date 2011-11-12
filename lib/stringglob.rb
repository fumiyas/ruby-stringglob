## Ruby StringGlob: Generate a Regexp object from a glob(3) pattern
##
## Author:: SATOH Fumiyasu
## Copyright:: (c) 2007-2011 SATOH Fumiyasu @ OSS Technology, Corp.
## License:: You can redistribute it and/or modify it under the same term as Ruby.
## Date:: 2011-11-01, since 2009-07-15
##

## This is a Ruby version of Perl Text::Glob 0.08
## Copyright (c) 2002, 2003, 2006, 2007 Richard Clamp.  All Rights Reserved.

require "stringglob/version"

## Generate a Regexp object from a glob(3) pattern
module StringGlob
  ## Ignore case.
  IGNORE_CASE =			1 << 0
  ## Leading star '*' matches leading dot '.'.
  STAR_MATCHES_LEADING_DOT = 	1 << 1
  ## Star '*' matches slash '/'.
  STAR_MATCHES_SLASH =	        1 << 2

  ## Returns a Regex object which is the equivalent of the globbing pattern.
  def regexp(glob, opt = 0, code = nil)
    re = regexp_string(glob, opt)
    return Regexp.new("\\A#{re}\\z", nil, code)
  end
  module_function :regexp

  ## Returns a regexp String object which is the equivalent of the globbing pattern.
  def regexp_string(glob, opt = 0)
    re_str = ''
    in_curlies = 0
    escaping = false
    first_byte = true
    asterisk = false
    star_matches_leading_dot = (opt & STAR_MATCHES_LEADING_DOT == 0)
    star_matches_slash = (opt & STAR_MATCHES_SLASH == 0)
    glob.scan(/./m) do |glob_c|
      if first_byte
	if star_matches_leading_dot
	  re_str += '(?=[^\.])' unless glob_c == '.'
	end
	first_byte = false
      end
      if asterisk && glob_c != '*'
	re_str += star_matches_slash ? '[^/]*' : '.*'
	asterisk = false
      end
      if glob_c == '/'
	first_byte = true
      end
      if ('.()|+^$@%'.include?(glob_c))
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
	  star_matches_slash ? '[^/]' : '.'
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
      re_str += star_matches_slash ? '[^/]*' : '.*'
    end

    re_str = "(?i:#{re_str})" if (opt & IGNORE_CASE != 0)

    return re_str
  end
  module_function :regexp_string
end

