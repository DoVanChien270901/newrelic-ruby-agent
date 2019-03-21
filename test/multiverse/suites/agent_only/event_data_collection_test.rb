# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

require 'newrelic_rpm'

class EventDataCollectionTest < Minitest::Test
  include MultiverseHelpers

  def test_sends_all_event_capacities_on_connect
    expected = {
      'harvest_limits' => {
        "analytic_event_data" => 1200,
        "custom_event_data" => 1000,
        "error_event_data" => 100
      }
    }

    setup_agent

    assert_equal expected, single_connect_posted['event_data']
  end

  def test_adjusts_event_report_period
    connect_response = {
      "agent_run_id" => 1,
      "event_data" => {
        "report_period_ms" => 5000,
        "harvest_limits" => {
          "analytic_event_data" => 1200,
          "custom_event_data" => 1000,
          "error_event_data" => 100
        }
      }
    }

    setup_agent
    $collector.stub('connect', connect_response)
    trigger_agent_reconnect

    assert_equal 5, NewRelic::Agent.config[:event_report_period]
  end
end