# Student quick start / התחלה מהירה לסטודנט

One page. Deploy the lab in **your own** Learner Lab, connect, and — most important — **stop it when you finish**.

---

## English

### 1. Start your lab
1. Open AWS Academy → your **Learner Lab** → **Start Lab**. Wait until the status dot is **green**.
2. Find your public IP: open <https://checkip.amazonaws.com> and copy the number.

### 2. Launch the stack
1. Click the **Launch stack** link your instructor gave you (it opens AWS CloudFormation with the template loaded).
2. Fill the parameters:
   - **StudentIP** → `YOUR.IP.HERE/32` (the number from step 1, with `/32`).
   - **KasmDesktopPassword** → pick a password you'll remember.
   - Leave the rest as default unless told otherwise.
3. Click through **Next → Next → Create stack**. Wait for **CREATE_COMPLETE**, then wait **~10 more minutes** for the machines to finish setting themselves up.

### 3. Connect
1. Open the **Outputs** tab of the stack. Copy **AttackerDesktopURL** (looks like `https://<ip>:6901`).
2. Open it in your browser. You'll see a security warning about the certificate — that's expected, click **Advanced → Proceed**.
3. Log in: user **`kasm_user`**, password = the one you set.
4. You now have a Kali Linux desktop in your browser. The vulnerable apps are on the **target** machine — use the **TargetPrivateIP** from Outputs, e.g. `http://10.20.1.23:3000` for Juice Shop.

### 4. ⛔ STOP when you finish (every time!)
- Go to **EC2 → Instances**, select both machines, **Instance state → Stop**. (Stop, not Terminate.)
- Or just click **End Lab** in Learner Lab.
- **Why:** running machines spend your lab credit continuously. The credit is small and lasts the whole course. If you forget, you can run out and lose access.

### 💰 Cost warning
Two `t3.large` machines cost roughly **$0.17 per hour** combined. Left running 24/7 they would burn ~**$120/month** — far more than your lab credit. **Stopped machines cost almost nothing.** Always stop at the end.

---

<div dir="rtl">

## עברית

### 1. הפעלת המעבדה
1. היכנסו ל־AWS Academy ← ה־**Learner Lab** שלכם ← **Start Lab**. המתינו עד שהנקודה תהפוך ל**ירוקה**.
2. מצאו את כתובת ה־IP הציבורית שלכם: היכנסו ל־<https://checkip.amazonaws.com> והעתיקו את המספר.

### 2. הקמת ה־Stack
1. לחצו על קישור ה־**Launch stack** שקיבלתם מהמרצה (הוא פותח את AWS CloudFormation עם התבנית טעונה).
2. מלאו את הפרמטרים:
   - **StudentIP** ← `כתובת.ה־IP.שלכם/32` (המספר משלב 1, עם `/32` בסוף).
   - **KasmDesktopPassword** ← בחרו סיסמה שתזכרו.
   - את שאר השדות השאירו כברירת מחדל, אלא אם נאמר אחרת.
3. לחצו **Next ← Next ← Create stack**. המתינו ל־**CREATE_COMPLETE**, ואז המתינו **עוד כ־10 דקות** שהמכונות יסיימו להתקין את עצמן.

### 3. התחברות
1. פתחו את לשונית ה־**Outputs** של ה־Stack. העתיקו את **AttackerDesktopURL** (נראה כמו `https://<ip>:6901`).
2. פתחו אותו בדפדפן. תופיע אזהרת אבטחה לגבי התעודה — זה צפוי, לחצו **Advanced ← Proceed**.
3. התחברו: משתמש **`kasm_user`**, סיסמה = זו שהגדרתם.
4. קיבלתם שולחן עבודה של Kali Linux בדפדפן. האפליקציות הפגיעות נמצאות על מכונת ה־**target** — השתמשו בכתובת **TargetPrivateIP** מתוך ה־Outputs, לדוגמה `http://10.20.1.23:3000` עבור Juice Shop.

### 4. ⛔ עצרו את המכונות בסיום (בכל פעם!)
- היכנסו ל־**EC2 ← Instances**, סמנו את שתי המכונות, **Instance state ← Stop**. (Stop, לא Terminate.)
- או פשוט לחצו **End Lab** ב־Learner Lab.
- **למה:** מכונות שרצות צורכות את תקציב המעבדה שלכם באופן רציף. התקציב קטן ואמור להספיק לכל הקורס. אם תשכחו — הוא עלול להיגמר ותאבדו גישה.

### 💰 אזהרת עלות
שתי מכונות `t3.large` עולות יחד בערך **0.17$ לשעה**. אם יישארו דולקות 24/7 הן יבזבזו כ־**120$ בחודש** — הרבה מעבר לתקציב. **מכונות עצורות כמעט לא עולות כלום.** תמיד עצרו בסיום.

</div>

---

> **Rules of the lab / כללי המעבדה:** attack **only** the target machine inside your own lab. Never attack other machines, other students, AWS itself, or anything on the internet. תוקפים **אך ורק** את מכונת ה־target בתוך המעבדה שלכם. אסור לתקוף מכונות אחרות, סטודנטים אחרים, את AWS עצמה, או כל דבר באינטרנט. (See `docs/safety.md`.)
