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
        
    #Verification of an return url signed using signature version 1.
    params = {}
    params["expiry"] = "10/2013";
    params["tokenID"] = "Q5IG5ETFCEBU8KBLTI4JHINQVL6VAJVHICBRR49AKLPIEZH1KB1S8C7VHAJJMLJ3";
    params["status"] = "SC";
    params["callerReference"] = "1253247023946cMcrTRrjtLjNrZGNKchWfDtUEIGuJfiOBAAJYPjbytBV";
    params["signature"] = "IBUljqQYfKe4bdZU8YlCtcHmRBA=";

    print "Verifying IPN signed using signature v1 ....\n";
    print "Is signature correct: ", utils.validate_request(:parameters => params), "\n";

    #New parameters sent in IPN signed using signature v2
    params["signatureMethod"] = "RSA-SHA1";
    params["signatureVersion"] = "2";
    params["certificateUrl"] = "https://fps.amazonaws.com/certs/090909/PKICert.pem";
    params["signature"] = "H4NTAsp3YwAEiyQ86j5B53lksv2hwwEaEFxtdWFpy9xX764AZy/Dm0RLEykUUyPVLgqCOlMopay5" \
        + "Qxr/VDwhdYAzgQzA8VCV8x9Mn0caKsJT2HCU6tSLNa6bLwzg/ildCm2lHDho1Xt2yaBHMt+/Cn4q" \
        + "I5B+6PDrb8csuAWxW/mbUhk7AzazZMfQciJNjS5k+INlcvOOtQqoA/gVeBLsXK5jNsTh09cNa7pb" \
        + "gAvey+0DEjYnIRX+beJV6EMCPZxnXDGo0fA1PENLWXIHtAoIJAfLYEkVbT2lva2tZ0KBBWENnSjf" \
        + "26lMZVokypIo4huoGaZMp1IVkImFi3qC6ipCrw==";

    url_end_point = "http://www.mysite.com/call_pay.jsp"; #Your return url end point.
         
    print "Verifying IPN signed using signature v2 ....\n";
    #return url is sent as a http GET request and hence we specify GET as the http method.
    #Signature verification does not require your secret key
    print "Is signature correct: ", utils.validate_request(:parameters => params, :url_end_point => url_end_point, :http_method => "GET"), "\n";
  end
end

end
end

#Test 
Amazon::FPS::IPNVerificationSampleCode.test()
