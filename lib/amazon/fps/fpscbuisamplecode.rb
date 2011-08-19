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

class FPSCBUISampleCode

  #Set these values depending on the service endpoint you are going to hit
  @@app_name = "CBUI"
  @@http_method = "GET"
  @@service_end_point = "https://authorize.payments-sandbox.amazon.com/cobranded-ui/actions/start"
  @@cbui_version = "2009-01-09"

  @@access_key = "<Paste your access key id here>"
  @@secret_key = "<Paste your secret key here>"

  def self.get_cbui_params(amount, pipeline, caller_reference, payment_reason, return_url, signature_version, signature_method)
    params = {}
    params["callerKey"] = @@access_key
    params["transactionAmount"] = amount
    params["pipelineName"] = pipeline
    params["returnUrl"] = return_url
    params["version"] = @@cbui_version
    params["callerReference"] = caller_reference unless caller_reference.nil?
    params["paymentReason"] = payment_reason unless payment_reason.nil?
    if (signature_version.nil?) then
        params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "1"
    else
        params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = signature_version
    end
    params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = signature_method unless signature_method.nil?
    
    return params
  end

  def self.get_cbui_url(params)
    cbui_url = @@service_end_point + "?"

    isFirst = true
    params.each { |k,v|
      if(isFirst) then
        isFirst = false
      else
        cbui_url << '&'
      end

      cbui_url << Amazon::FPS::SignatureUtils.urlencode(k)
      unless(v.nil?) then
        cbui_url << '='
        cbui_url << Amazon::FPS::SignatureUtils.urlencode(v)
      end
    }
    return cbui_url
  end

  def self.test()
    uri = URI.parse(@@service_end_point)
    params = get_cbui_params("1.1", "SingleUse", "YourCallerReference", "<paymentReason>", 
                    "http://yourwebsite.com/return.html", "2", Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM);

    signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => params, 
                                            :aws_secret_key => @@secret_key,
                                            :host => uri.host,
                                            :verb => @@http_method,
                                            :uri  => uri.path })
    params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature
    print get_cbui_url(params), "\n"
  end
end

end
end

Amazon::FPS::FPSCBUISampleCode.test()

