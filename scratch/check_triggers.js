const mysql = require('mysql2/promise');

async function run() {
  const connection = await mysql.createConnection({
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'password',
    database: 'device_portal'
  });

  try {
    const [triggers] = await connection.query("SHOW TRIGGERS");
    console.log("=== TRIGGERS ===");
    console.log(JSON.stringify(triggers, null, 2));

    const [screens] = await connection.query("SELECT * FROM screen");
    console.log("=== SCREENS ===");
    console.log(screens);

    const [userTypeScreens] = await connection.query("SELECT * FROM user_type_screen");
    console.log("=== USER_TYPE_SCREEN ===");
    console.log(userTypeScreens);

  } catch (err) {
    console.error("Error:", err);
  } finally {
    await connection.end();
  }
}

run();
