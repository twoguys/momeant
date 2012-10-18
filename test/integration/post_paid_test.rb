# success
# http://momeant.dev/fund/accept-postpaid?signatureMethod=RSA-SHA1&status=SC&creditSenderTokenID=I5GIP372QXEV2ZA9JBAQ3FFJ3YQDB2GBF8TF68H8D37VL3LB6VTJFQ4F9ZZ6DZDK&creditInstrumentID=I7GIB3T2Q8EU2ZK9CBAI31FJXY9DB7G2F8QF78HCDA7VM3MB6QTQFQTFHZZGD3DG&settlementTokenID=I1GII3G2QUE82ZI9DBA534FJNYZDB7G8F8JFS8HHDC7VL36B6BT3FQ9FJZZFDKD6&signatureVersion=2&signature=VztSCPvJH0s1Hgg7TvLEDB5hF7R3VIXO12BRzuihITwakjzUQlXOyLDUbsbi4ct9YCkyColoUndZ%0AoNlV2mUb%2BRFC6ixatKuUUDjIxOD07Awh7SClNzk4vxVIRouZeP5ROAZpm33tvRnH66XHr%2FEvqdW%2F%0A6NzAw0HOgVFAeRyvixo%3D&certificateUrl=https%3A%2F%2Ffps.sandbox.amazonaws.com%2Fcerts%2F090911%2FPKICert.pem%3FrequestId%3D1mibf30suu4kx9ssye1joafw1mjjdejt45oc7v86z5hifxn41k&expiry=02%2F2017

# error
# http://momeant.dev/fund/accept-postpaid?errorMessage=The+following+input%28s%29+are+not+well+formed%3A[callerReferenceSettlement]&signatureMethod=RSA-SHA1&status=CE&signatureVersion=2&signature=nnY%2Bdk1%2BE%2BWdFk7%2B2PLCXpbuEb5ZqLfXt9l%2BRdcalZsRZ7OMoChwjp008%2BfpiuzmgLLjiC0riC77%0Aua7C36JbbkdlsOflgJOppnvQrylDfvWTVoPYQ2eg0CiuMdQqGqx6NpLsz4ZUuscognGn%2FxoHXD4n%0ANuAxpMkp5Qd4ZguC%2BsU%3D&certificateUrl=https%3A%2F%2Ffps.sandbox.amazonaws.com%2Fcerts%2F090911%2FPKICert.pem%3FrequestId%3D1mibf30suu4kx9ssye1joafw1mjjdejt45oc7v86z5hifxn41k

# Status Codes
# SA - Success status for the ABT payment method.
# SB - Success status for the ACH (bank account) payment method.
# SC - Success status for the credit card payment method.
# SE - System error.
# A - Buyer abandoned the pipeline.
# CE - Specifies a caller exception.
# PE - Payment Method Mismatch Error: Specifies that the user does not have payment method that you have requested.
# NP - There are four cases where the NP status is returned:
#   The payment instruction installation was not allowed on the sender's account, because the sender's email account is not verified
#   The sender and the recipient are the same
#   The recipient account is a personal account, and therefore cannot accept credit card payments
#   A user error occurred because the pipeline was cancelled and then restarted
# NM - You are not registered as a third-party caller to make this transaction. Contact Amazon Payments for more information