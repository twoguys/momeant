require 'uri'
require 'amazon/fps/signatureutils'

module Amazon
  module FPS

    class Payments

      def self.create_url(url, params)
        url = url + "?"

        isFirst = true
        params.each { |k,v|
          if(isFirst) then
            isFirst = false
          else
            url << '&'
          end

          url << Amazon::FPS::SignatureUtils.urlencode(k)
          unless(v.nil?) then
            url << '='
            url << Amazon::FPS::SignatureUtils.urlencode(v)
          end
        }
        return url
      end

      def self.get_cobranded_url(amount, payment_reason, unique_id, return_url)
        uri = URI.parse(ENV["AMAZON_CBUI_ENDPOINT"])
        parameters = {}
        parameters["callerKey"] = ENV["S3_KEY"]
        parameters["transactionAmount"] = amount
        parameters["pipelineName"] = "SingleUse"
        parameters["returnUrl"] = return_url
        parameters["version"] = "2009-01-09"
        parameters["callerReference"] = unique_id
        parameters["paymentReason"] = payment_reason unless payment_reason.nil?
        parameters["cobrandingStyle"] = "logo"
        parameters["cobrandingUrl"] = "https://momeant-production.s3.amazonaws.com/assets/logoBlackSmall.png"
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
        signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => parameters, 
                                                :aws_secret_key => ENV["S3_SECRET"],
                                                :host => uri.host,
                                                :verb => "GET",
                                                :uri  => uri.path })
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature
    
        return create_url(ENV["AMAZON_CBUI_ENDPOINT"], parameters)
      end
    
      def self.get_pay_url(amount, token_id)
        uri = URI.parse(ENV["AMAZON_FPS_ENDPOINT"])
        parameters = {}
        parameters["AWSAccessKeyId"] = ENV["S3_KEY"]
        parameters["Version"] = "2008-09-17"
        parameters["Timestamp"] = Time.now.iso8601.to_s
        parameters["Action"] = "Pay"
        parameters["TransactionAmount.Value"] = amount
        parameters["TransactionAmount.CurrencyCode"] = "USD"
        parameters["SenderTokenId"] = token_id
        parameters["CallerReference"] = token_id
        parameters["CallerDescription"] = "Momeant"
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
        signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => parameters, 
                                                :aws_secret_key => ENV["S3_SECRET"],
                                                :host => uri.host,
                                                :verb => "GET",
                                                :uri  => uri.path })
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

        return create_url(ENV["AMAZON_FPS_ENDPOINT"], parameters)
      end
  
      def self.get_postpaid_cobranded_url(user_id, return_url)
        uri = URI.parse(ENV["AMAZON_CBUI_ENDPOINT"])
        parameters = {}
        parameters["callerKey"] = ENV["S3_KEY"]
        parameters["pipelineName"] = "SetupPostpaid"
        parameters["callerReferenceSettlement"] = user_id
        parameters["callerReferenceSender"] = user_id
        parameters["globalAmountLimit"] = 1000
        parameters["creditLimit"] = 1
        parameters["returnURL"] = return_url
        parameters["version"] = "2009-01-09"
        parameters["cobrandingStyle"] = "logo"
        parameters["cobrandingUrl"] = "https://momeant-production.s3.amazonaws.com/assets/logoBlackSmall.png"
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
        signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => parameters, 
                                                :aws_secret_key => ENV["S3_SECRET"],
                                                :host => uri.host,
                                                :verb => "GET",
                                                :uri  => uri.path })
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature
        
        return create_url(ENV["AMAZON_CBUI_ENDPOINT"], parameters)
      end
      
      def self.get_postpaid_settle_url(amount, payment_id, credit_instrument_id, settlement_token_id)
        uri = URI.parse(ENV["AMAZON_FPS_ENDPOINT"])
        parameters = {}
        parameters["AWSAccessKeyId"] = ENV["S3_KEY"]
        parameters["Action"] = "SettleDebt"
        parameters["CallerDescription"] = "Momeant"
        parameters["CallerReference"] = payment_id
        parameters["CreditInstrumentId"] = credit_instrument_id
        parameters["SenderTokenId"] = settlement_token_id
        parameters["SettlementAmount.Value"] = amount
        parameters["SettlementAmount.CurrencyCode"] = "USD"
        parameters["Version"] = "2008-09-17"
        parameters["Timestamp"] = Time.now.iso8601.to_s
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
        signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => parameters, 
                                                :aws_secret_key => ENV["S3_SECRET"],
                                                :host => uri.host,
                                                :verb => "GET",
                                                :uri  => uri.path })
        parameters[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

        return create_url(ENV["AMAZON_FPS_ENDPOINT"], parameters)
      end
  
    end

  end
end