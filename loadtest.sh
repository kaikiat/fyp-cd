
printf $"Please select an option \n1) Test canary \n2) Test preview service (blueGreen) \n3) Test original service (blueGreen) \n"
read input
echo $input
if [ $input == "1" ]; then
    python3 suite/canary.py
elif [ $input == "2" ]; then
    echo "WIP"
else
    echo "WIP"
fi
