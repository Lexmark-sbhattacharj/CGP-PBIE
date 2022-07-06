/etc/init.d/postgresql stop
sleep 5
/etc/init.d/postgresql start
sleep 5
./precompile.sh && ./setenv.sh && ./bin/rails s