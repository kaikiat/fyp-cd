
printf $"Please select an option \n1) Test canary \n2) Test preview service (blueGreen) \n3) Test original service (blueGreen) \n"
read input
echo $input
if [ $input == "1" ]; then
    echo "canary testing"
elif [ $input == "2" ]; then
    echo "preview testing"
else
    echo "original"
fi
