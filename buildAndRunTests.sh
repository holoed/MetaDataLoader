export NODE_PATH="$NODE_PATH:./output"
rm -rf output

pulp build
mocha "test/**/*.js"
