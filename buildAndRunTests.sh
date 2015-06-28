export NODE_PATH="$NODE_PATH:./output"
rm -rf output

mv src/HttpClient.purs src/HttpClient.bak
cp src/HttpClient.stub src/HttpClient.purs
pulp build
node tester.js
mv src/HttpClient.bak src/HttpClient.purs
