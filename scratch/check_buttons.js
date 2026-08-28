const fs = require('fs');
const path = require('path');

const jspDir = 'src/main/webapp/WEB-INF/jsp';
const files = fs.readdirSync(jspDir);

files.forEach(file => {
  if (file.endsWith('.jsp')) {
    const content = fs.readFileSync(path.join(jspDir, file), 'utf8');
    if (content.includes('applyFiltersBtn')) {
      const lines = content.split('\n');
      lines.forEach((line, i) => {
        if (line.includes('applyFiltersBtn')) {
          console.log(`=== ${file}:${i+1} ===`);
          // Print 15 lines before
          const start = Math.max(0, i - 15);
          const end = Math.min(lines.length - 1, i + 10);
          for (let j = start; j <= end; j++) {
            console.log(`${j+1}: ${lines[j].trim()}`);
          }
        }
      });
    }
  }
});
