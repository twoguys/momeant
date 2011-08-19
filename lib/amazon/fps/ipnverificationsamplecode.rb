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

require 'signatureutilsforoutbound'

module Amazon
module FPS

class IPNVerificationSampleCode

  def self.test()
    aws_access_key = "MyAccessKey"; #Your aws access key
    aws_secret_key = "MySecretKey"; #Your aws secret key
    utils = Amazon::FPS::SignatureUtilsForOutbound.new(aws_access_key, aws_secret_key);
        
    # Verification of an IPN signed using signature version 1.
    # 1. Parameters present in ipn.
    params = {}
    params["transactionId"] = "14DRG2JGR7LK4J54P544DKKNDLQFFZLE323";
    params["transactionDate"] = "1251832057";
    params["status"] = "INITIATED";
    params["notificationType"] = "TransactionStatus";
    params["callerReference"] = "callerReference=ReferenceStringJYI1251832057319108";
    params["operation"] = "PAY";
    params["transactionAmount"] = "USD 1.00";
    params["buyerName"] = "BuyerName-SsUo3oDjHx";
    params["paymentMethod"] = "CC";
    params["paymentReason"] = "DescriptionString-1251832057319108";
    params["recipientEmail"] = "recipientemail@amazon.com";
    params["signature"] = "VEAAvfPO2F0IGaDGXYemaQQfzkA=";

    print "Verifying IPN signed using signature v1 ....\n";
    print "Is signature correct: ", utils.validate_request(:parameters => params), "\n";

    #New parameters sent in IPN signed using signature v2
    params["signatureMethod"] = "RSA-SHA1";
    params["signatureVersion"] = "2";
    params["certificateUrl"] = "https://fps.amazonaws.com/certs/090909/PKICert.pem";
    params["signature"] = "vKXXCbtxvSkRR+Zn8YNW6DNGpbi474h2iM4L+xaOi16kYKdYpuGbvKyXQ36uTZTVHdUGAAcvpXFL" \
      + "wDfnTcqcckr2IUElrVJKQeT0WeWR+IqmABwSRGo+YqjzPNISSNXNzg6LFhouhUvmmwY15X3YgXfc" \
      + "ERN5IhPwv04YkyCLPCA9P0/QgD8Jum/hc9jj0HYjj3s3MuuQ3yoIhf2x+2CBZRm5lslRqnoF/8OJ" \
      + "1ZHmAHt9VvQSZ+QC3fwJgeqzJPAvtuOm930BP6hPYZVhXE5w7ByLt0qLk1ZFE/vzQ4io4vOyie6W" \
      + "bhp5+AuNyAs+QrGMYO8VZruZJfkZO4b6QOgV2A==";

    url_end_point = "http://www.mysite.com/ipn.jsp"; #Your url end point receiving the ipn.
         
    print "Verifying IPN signed using signature v2 ....\n";
    #IPN is sent as a http POST request and hence we specify POST as the http method.
    #Signature verification does not require your secret key
    print "Is signature correct: ", utils.validate_request(:parameters => params, :url_end_point => url_end_point, :http_method => "POST"), "\n";
  end
end

end
end

#Test 
Amazon::FPS::IPNVerificationSampleCode.test()
