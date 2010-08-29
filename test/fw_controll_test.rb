require 'test_helper'
require 'action_controller'
require 'active_support/test_case'

class FwControllTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def fw_rules_list
    if fw_rules_list.length > 2
      assert true 
    else
      assert false
    end
  end

  def fw_rule_add
    assert_equal true, false
  end
end
