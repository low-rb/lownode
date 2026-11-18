# frozen_string_literal: true

require 'uri'

module Low
  module Responses
    # A cookie for a response to set, as its "set-cookie" header. Defaults to the safest settings.
    class Cookie
      DEFAULTS = { path: '/', max_age: nil, http_only: true, secure: true, same_site: 'Lax' }.freeze
      SAME_SITES = %w[Strict Lax None].freeze

      def initialize(name:, value:, **options)
        unknown = options.keys - DEFAULTS.keys
        raise ArgumentError, "Unknown cookie options: #{unknown.join(', ')}" if unknown.any?

        @name = name
        @value = value
        @options = DEFAULTS.merge(options)
        raise ArgumentError, "same_site is one of #{SAME_SITES.join(', ')}" unless SAME_SITES.include?(@options[:same_site])
      end

      def to_s
        attributes = ["#{@name}=#{URI.encode_www_form_component(@value.to_s)}", "Path=#{@options[:path]}"]
        attributes << "Max-Age=#{@options[:max_age].to_i}" if @options[:max_age]
        attributes << 'HttpOnly' if @options[:http_only]
        attributes << 'Secure' if @options[:secure]
        attributes << "SameSite=#{@options[:same_site]}"
        attributes.join('; ')
      end
    end
  end
end
