# Variables.
# Address of the SIGNA account between double quotes, example : "S-ABCD-1234-ABCD-12345"
$account = ""

# Secret phrase between double quotes and replace spaces with +, example : "my+secret+phrase+1234+abcd"
# WARNING !!!
# DO NOT put this file in a shared folder of any sort, nor inside a folder of any file sharing service.
# DO NOT use this file as a way to save your secret phrase, always save your sensitive data in a secure way, not an unencrypted file on your pc/server.
$sp = ""

$pk = Invoke-RestMethod -Method GET -Uri "http://localhost:8125/api?requestType=getAccountPublicKey&account=$account" | Select-Object -ExpandProperty publickey
[int64]$cheapestFee = Invoke-RestMethod -Method GET -Uri "http://localhost:8125/api?requestType=suggestFee" | Select-Object -ExpandProperty cheap
$attemptsCount = 0

Do {
    $rawBalance = Invoke-RestMethod -Method GET -Uri "http://localhost:8125/api?requestType=getBalance&account=$account"
    $intRawBalance = [int64]$rawBalance.unconfirmedBalanceNQT
    $intBalanceMinusFee = $intRawBalance - $cheapestFee
    # If you want to change the minimum amount for commitment, always make sure there are 8 numbers in the decimal positions, example : 150 SIGNA = 15000000000 or 150.11 SIGNA = 15011000000.
    If ($intRawBalance -ge 9500000000) {
        Invoke-RestMethod -Method POST -Uri "http://localhost:8125/api?requestType=addCommitment&amountNQT=$intBalanceMinusFee&feeNQT=1000000&secretPhrase=$sp&publicKey=$pk&deadline=60&broadcast=true"
        Start-Sleep -Milliseconds 30000
        exit
    }
    $attemptsCount++
    Start-Sleep -Milliseconds 20000
    Write-Host "Attempt number" $attemptsCount -ForegroundColor White -BackgroundColor Black
# If free balance never goes over minimum amount, the script shuts off after 90 minutes (270 attempts * 20 seconds = 5400 seconds = 90 minutes).
} Until ($attemptsCount -eq 270)