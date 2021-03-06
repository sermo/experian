require 'test_helper'

describe Experian::PreciseId::Client do
  before do
    @logger = Experian.logger = stub(debug: nil)
    @client = Experian::PreciseId::Client.new
    stub_experian_request("precise_id", "primary-response.xml")
  end

  it "performs a precise id check" do
    request,response = @client.check_id
    assert_kind_of Experian::PreciseId::PrimaryRequest, request
    assert_kind_of Experian::PreciseId::Response, response
  end

  it "logs the raw response if an unidentified error is detected" do
    response = stub({
      status:200,
      body:"<NetConnectResponse><CompletionCode>0000</CompletionCode><ReferenceId/></NetConnectResponse>",
      headers:{}
    })
    @client.stubs(:post_request).returns(response)
    @logger.expects(:debug).with("Unknown Experian Error Detected, Raw response: #{response.inspect}")
    @client.check_id
  end

  it "performs a secondary inquiry" do
    request,response = @client.request_questions
    assert_kind_of Experian::PreciseId::SecondaryRequest, request
    assert_kind_of Experian::PreciseId::Response, response
  end

  it "performs a final inquiry" do
    request,response = @client.send_answers
    assert_kind_of Experian::PreciseId::FinalRequest, request
    assert_kind_of Experian::PreciseId::Response, response
  end

end
