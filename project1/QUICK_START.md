# 🎯 QUICK START - SkillXchange Backend

## ✅ 3 Simple Steps to Get Started

### Step 1: Start XAMPP
- Open XAMPP Control Panel
- Click **Start** for **Apache** ✓
- Click **Start** for **MySQL** ✓

### Step 2: Run SQL Script
1. Open: **http://localhost/phpmyadmin**
2. Click **"SQL"** tab
3. Open file: `project1/backend/database_setup.sql`
4. Copy **ENTIRE** content
5. Paste in SQL tab
6. Click **"Go"**
7. ✅ Done!

### Step 3: Test Application
**Open:** http://localhost/WEBSWAP/project1/index.html

**Login with:**
- Email: `test@example.com`
- Password: `password123`

---

## 📁 Your Project Structure

```
project1/              ← YOUR MAIN FOLDER
├── index.html
├── signup.html
├── signin.html
├── home.html
├── styles.css
├── auth.js
├── home.js
└── backend/          ← BACKEND IS HERE
    ├── config/
    │   ├── database.php
    │   └── cors.php
    ├── api/
    │   ├── signup.php
    │   ├── signin.php
    │   ├── logout.php
    │   └── check_auth.php
    └── database_setup.sql  ⭐ RUN THIS!
```

---

## 📋 SQL File to Run

**Location:** `project1/backend/database_setup.sql`

**Creates:**
- Database: `skillxchange_db`
- 10 tables with sample data
- 1 test user (test@example.com / password123)

---

## ✅ Success Checklist

- [ ] XAMPP Apache & MySQL running (green)
- [ ] Ran database_setup.sql in phpMyAdmin
- [ ] Can see `skillxchange_db` in database list
- [ ] Can open project1/index.html in browser
- [ ] Can login with test credentials

---

**All checked? You're done! 🚀**

**Having issues?** Check `README_BACKEND.md` for troubleshooting.
