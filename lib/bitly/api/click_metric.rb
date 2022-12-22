# frozen_string_literal: true
require_relative "./base"
require_relative './list'

module Bitly
  module API
    class ClickMetric
      include Base

      class List < Bitly::API::List
        attr_reader :units, :unit_reference, :unit, :facet
        def initialize(items: nil, response: nil, units: nil, unit_reference: nil, unit: nil, facet: nil)
          super(items: items, response: response)
          @units = units
          # It looks like the API for referrers_by_domain returns the
          # unit_reference in seconds, not a string, like every other endpoint.
          begin
            @unit_reference = Time.parse(unit_reference) if unit_reference
          rescue TypeError
            @unit_reference = Time.at(unit_reference)
          end
          @unit = unit
          @facet = facet
        end
      end

      class Referrers < Bitly::API::List
        attr_reader :network
        def initialize(items: nil, response: nil, network: nil)
          super(items: items, response: response)
          @network = network
        end
      end

      ##
      # Gets the referring networks for the group.
      # [`GET /v4/groups/{group_guid}/referring_networks`](https://dev.bitly.com/v4/#operation/GetGroupMetricsByReferringNetworks)
      #
      # @param client [Bitly::API::Client] An authorized API client
      # @param group_guid [String] The guid of the group
      # @param unit [String] A unit of time. Default is "day" and can be
      #     "minute", "hour", "day", "week" or "month"
      # @param units [Integer] An integer representing the time units to query
      #     data for. pass -1 to return all units of time. Defaults to -1.
      # @param unit_reference [String] An ISO-8601 timestamp, indicating the
      #     most recent time for which to pull metrics. Will default to current
      #     time.
      # @param size [Integer] The number of links to be returned. Defaults to 50
      #
      # @return [Bitly::API::ClickMetric::List]
      def self.list_referring_networks(client: nil, group_guid: nil, unit: nil, units: nil, size: nil, unit_reference: nil)
        list_metrics(
          client: client,
          path: "/groups/#{group_guid}/referring_networks",
          unit: unit,
          units: units,
          unit_reference: unit_reference,
          size: size
        )
      end

      ##
      # Gets the country click metrics for the group.
      # [`GET /v4/groups/{group_guid}/countries`](https://dev.bitly.com/v4/#operation/getGroupMetricsByCountries)
      #
      # @param client [Bitly::API::Client] An authorized API client
      # @param group_guid [String] The guid of the group
      # @param unit [String] A unit of time. Default is "day" and can be
      #     "minute", "hour", "day", "week" or "month"
      # @param units [Integer] An integer representing the time units to query
      #     data for. pass -1 to return all units of time. Defaults to -1.
      # @param unit_reference [String] An ISO-8601 timestamp, indicating the
      #     most recent time for which to pull metrics. Will default to current
      #     time.
      # @param size [Integer] The number of links to be returned. Defaults to 50
      #
      # @return [Bitly::API::ClickMetric::List]
      def self.list_countries_by_group(client: nil, group_guid: nil, unit: nil, units: nil, size: nil, unit_reference: nil)
        list_metrics(
          client: client,
          path: "/groups/#{group_guid}/countries",
          unit: unit,
          units: units,
          unit_reference: unit_reference,
          size: size
        )
      end

      def self.list_referrers(client: nil, bitlink: nil, unit: nil, units: nil, size: nil, unit_reference: nil)
        list_metrics(
          client: client,
          path: "/bitlinks/#{bitlink}/referrers",
          unit: unit,
          units: units,
          unit_reference: unit_reference,
          size: size
        )
      end

      def self.list_countries_by_bitlink(client: nil, bitlink: nil, unit: nil, units: nil, size: nil, unit_reference: nil)
        list_metrics(
          client: client,
          path: "/bitlinks/#{bitlink}/countries",
          unit: unit,
          units: units,
          unit_reference: unit_reference,
          size: size
        )
      end

      def self.list_referring_domains(client: nil, bitlink: nil, unit: nil, units: nil, size: nil, unit_reference: nil)
        list_metrics(
          client: client,
          path: "/bitlinks/#{bitlink}/referring_domains",
          unit: unit,
          units: units,
          unit_reference: unit_reference,
          size: size
        )
      end

      def self.list_referrers_by_domain(client: nil, bitlink: nil, unit: nil, units: nil, size: nil, unit_reference: nil)
        response = client.request(
          path: "/bitlinks/#{bitlink}/referrers_by_domains",
          params: {
            "unit" => unit,
            "units" => units,
            "unit_reference" => unit_reference,
            "size" => size
          }
        )
        body = response.body
        referrers = body["referrers_by_domain"].map do |referrer|
          click_metrics = referrer["referrers"].map do |metric|
            ClickMetric.new(data: metric)
          end
          Referrers.new(items: click_metrics, response: response, network: referrer["network"])
        end
        List.new(
          items: referrers,
          response: response,
          unit: body["unit"],
          units: body["units"],
          unit_reference: body["unit_reference"],
          facet: body["facet"]
        )
      end

      def self.attributes
        [:clicks, :value]
      end
      attr_reader(*attributes)

      def initialize(data: nil)
        assign_attributes(data)
      end

      private

      def self.list_metrics(client: nil, path: nil, unit: nil, units: nil, size: nil, unit_reference: nil)
        response = client.request(
          path: path,
          params: {
            "unit" => unit,
            "units" => units,
            "unit_reference" => unit_reference,
            "size" => size
          }
        )
        body = response.body
        click_metrics = body["metrics"].map do |metric|
          ClickMetric.new(data: metric)
        end
        List.new(
          items: click_metrics,
          response: response,
          unit: body["unit"],
          units: body["units"],
          unit_reference: body["unit_reference"],
          facet: body["facet"]
        )
      end
    end
  end
end