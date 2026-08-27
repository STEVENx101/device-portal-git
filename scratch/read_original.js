const fs = require('fs');

const content = fs.readFileSync('original_CbsReportService.java', 'utf16le');
const lines = content.split('\n');
for (let i = 30; i <= 75; i++) {
  console.log(`${i}: ${lines[i-1]}`);
}
