
#
# Specifying scorn
#
# Tue Jan  5 11:06:04 JST 2021
#

require 'spec_helper'


describe Scorn do

  describe '.get' do

    it 'gets' do

      r = Scorn.get('https://reqbin.com')

      expect(r).to match(/<script>/)
    end

    it 'gets JSON' do

      r = Scorn.get('https://reqbin.com/echo/get/json')

      expect(r).to eq({ 'success' => 'true' })
    end
  end
end
