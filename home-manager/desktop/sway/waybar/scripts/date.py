from datetime import datetime

now = datetime.now()
japanese_day_names = {
    0: "月",
    1: "火",
    2: "水",
    3: "木",
    4: "金",
    5: "土",
    6: "日",
}
day_name = now.strftime("%A")
day_of_week = now.weekday()
japanese_day_name = japanese_day_names[day_of_week]
data = {
    "day": now.day,
    "month": now.month,
    "year": now.year,
    "hour": now.hour,
    "minute": now.minute,
    "second": now.second,
    "date_name": day_name,
    "japanese_date_name": japanese_day_name,
}
print(
    f"{data["year"]}/{data["month"]:02}/{data["day"]:02} "
    + f"{data["hour"]:02}:{data["minute"]:02} "
    + f"({data["japanese_date_name"]})"
)
