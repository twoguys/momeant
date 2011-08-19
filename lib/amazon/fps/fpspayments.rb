require 'uri'
require 'signatureutils'

module Amazon
module FPS

class FPSPayments

  #Set these values depending on the service endpoint you are going to hit
  @@app_name = "CBUI"
  @@http_method = "GET"
  @@service_end_point = 
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

  def self.get_redirect_url(amount, plan_name, return_url)
    uri = URI.parse(ENV["AMAZON_FPS_ENDPOINT"])
    params = get_cbui_params(
      amount.to_s,
      "SingleUse",
      "Momeant",
      plan_name, 
      return_url,
      "2",
      Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
    );

    signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => params, 
                                            :aws_secret_key => @@secret_key,
                                            :host => uri.host,
                                            :verb => @@http_method,
                                            :uri  => uri.path })
    params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature
    return get_cbui_url(params)
  end
end

end
end