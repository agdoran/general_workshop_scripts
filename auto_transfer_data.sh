#!/bin/sh

# 1 is the SSH key for access to the AWS machines
# 2 is the input text file of machine IPs (one per line)
# 3 is the path to the data directory to upload (pwd/pass_fastq)
# 4 is the path to the sequening summary file 
# e.g. command:
# ./auto_transfer_data.sh /path/to/ssh/key/*mac_key /text/file/of/ips/machines.txt /data/experiment/run_id/fastq_pass /data/experiment/run_id/experiment_sequencing_summary.txt

key=$1
machines=$2
data=$3
summ=$4

# ensure the input key has the correct permissions
chmod 600 $key

# print the input key and ip file to the terminal out

echo "-----------------------------\n"
echo "Keyfile: $key\nList of IP: $machines\nData directory to transfer: $data\n"
echo "-----------------------------\n"

counter=0

while read line; do

 # remove comment to print all the input lines (testing only)
 # echo $line

 # skip whitespace lines
 [ -z "$line" ] && continue

 # ip="${line/^.* //}"
 # ip=sed 's/^.* //'  < $line
 # template=$(echo $template | sed 's/old_string/new_string/g')
 ip=$(echo $line | sed 's/^.* //')
 out=$(echo nohup$counter.out)
 # echo RES $out

 #test the connection is true
 ssh -n -oStrictHostKeyChecking=no -i $key -q ubuntu@$ip exit

 #check if the connection was succesful
 if [ "$?" -eq "0" ]; then
  printf "[At line $counter]: successful connection to $line -IP: $ip\n\n"

  # if succesful start transfer
  # can make this a background transfer when working
  # this will need to  be changed to the location where we want to have the data ready for the analysis
  nohup rsync -r -z -e "ssh -i $key -o ServerAliveInterval=10 " --progress $data/*.fastq ubuntu@$ip:/home/ubuntu/data/ &> $out& 

  # transfer sequencing summary file from the experiment and call it sequencing_summary.txt
  # may need to include the --no-R --no-implied-dirs options though should be fine for one file
  rsync -r -z -e "ssh -i $key -o ServerAliveInterval=10 " --progress $summ ubuntu@$ip:/home/ubuntu/data/sequencing_summary.txt 

 # connection was refused
 elif [ "$?" -eq "255" ]; then
  printf "[At line $counter]: Could not connect to the machine at $line -IP: $ip - is your key correct?\n"
 else
  printf "[At line $counter]: Unknown connection error to $line -IP: $ip - please check input files\n"
 fi

 # aws_machines text file line counter
 counter=$(($counter + 1))

 echo "\n-----------------------------\n"

done < $machines

echo "\n-----------------------------\n"
printf "Connection test complete. Data transfers for successful connection tests above are running in background\n"
printf "These can be found as nohup and rsync jobs\n\n"
echo "-----------------------------\n\n\n"
