###############################################################################
 #  Copyright 2008-2010 Amazon Technologies, Inc
 #  Licensed under the Apache License, Version 2.0 (the "License");
 #
 #  You may not use this file except in compliance with the License.
 #  You may obtain a copy of the License at: http://aws.amazon.com/apache2.0
 #  This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 #  CONDITIONS OF ANY KIND, either express or implied. See the License for the
 #  specific language governing permissions and limitations under the License.
 ##############################################################################

require 'uri'
require 'signatureutils'

module Amazon
module FPS

class ASPPayNowSampleCode

  #Set these values depending on the service endpoint you are going to hit
  @@app_name = "ASP"
  @@http_method = "POST"
  @@service_end_point = "https://authorize.payments-sandbox.amazon.com/pba/paypipeline"

  @@access_key = "<Paste your access key id here>"
  @@secret_key = "<Paste your secret key here>"

  def self.get_paynow_widget_params(amount, description, reference_id, immediate_return,
            return_url, abandon_url, process_immediate, ipn_url, cobranding_style, signature_version, 
            signatureMethod)
    form_hidden_inputs = {}
    form_hidden_inputs["accessKey"] = @@access_key
    form_hidden_inputs["amount"] = amount
    form_hidden_inputs["description"] = description
    
    form_hidden_inputs["referenceId"] = reference_id unless reference_id.nil?
    form_hidden_inputs["immediateReturn"] = immediate_return unless immediate_return.nil?
    form_hidden_inputs["returnUrl"] = return_url unless return_url.nil?
    form_hidden_inputs["abandonUrl"] = abandon_url unless abandon_url.nil?
    form_hidden_inputs["processImmediate"] = process_immediate unless process_immediate.nil?
    form_hidden_inputs["ipnUrl"] = ipn_url unless ipn_url.nil?
    form_hidden_inputs["cobrandingStyle"] = cobranding_style unless cobranding_style.nil?
    form_hidden_inputs[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = signature_version unless signature_version.nil?
    form_hidden_inputs[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = signatureMethod unless signatureMethod.nil?
        
    return form_hidden_inputs
  end

  def self.get_paynow_widget_form(form_hidden_inputs)
    form = "<form action=\"" + @@service_end_point + "\" method=\"" + @@http_method + "\">\n"
    form += "<input type=\"image\" src=\"https://authorize.payments-sandbox.amazon.com/pba/images/payNowButton.png\" border=\"0\">\n"
    form_hidden_inputs.each { |k,v|
        form += "<input type=\"hidden\" name=\"" + k + "\" value=\"" + v + "\" >\n"
    }
    form += "</form>\n"
  end

  def self.test()
    uri = URI.parse(@@service_end_point)
    params = Amazon::FPS::ASPPayNowSampleCode.get_paynow_widget_params("USD 1.1", "Test Widget", "<referenceId>", "0", 
                    "http://yourwebsite.com/return.html", nil, "1",
                    "http://yourwebsite.com/ipn", "logo", "2", Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM)

    signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => params, 
                                            :aws_secret_key => @@secret_key,
                                            :host => uri.host,
                                            :verb => @@http_method,
                                            :uri  => uri.path })
    params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature
    paynow_widget_form = get_paynow_widget_form(params)
    print paynow_widget_form
  end
end

end
end


#Test 
#Amazon::FPS::ASPPayNowSampleCode.test()
