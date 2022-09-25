
printf $"Please select an option \n1) Test canary \n2) Test original service (Blue) \n3) Test preview service (Green) \n \n Please open a new command prompt for 2 & 3\n"
read input
echo $input
if [ $input == "1" ]; then
    python3 suite/canary.py
elif [ $input == "2" ]; then
    python3 suite/blue.py
else
    python3 suite/green.py
fi
