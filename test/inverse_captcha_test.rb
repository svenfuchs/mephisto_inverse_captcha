require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

require 'mephisto_controller'

class InverseCaptchaTest < Test::Unit::TestCase
  def test_should_add_methods_to_mephisto_controller
    assert_equal true, MephistoController.method_defined?(:kick_stupid_bots)
  end
  
  def test_should_register_param_exactly_once
    assert_equal 1, MephistoController.sneaky_params.size
    assert_equal 'InverseCaptcha::Param', MephistoController.sneaky_params.first.class.name
  end  
end
