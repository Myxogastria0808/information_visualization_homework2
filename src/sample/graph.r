library(ggplot2)
suppressMessages({
    library(showtext)
    # フォントの読み込み
    showtext::showtext_auto()
})

# データを読み込む
expo_data <- read.csv("../data/data.csv")

# 西暦順にラベルを並べる
label <- paste0(
    expo_data$name[order(expo_data$western_year)],
    " (",
    expo_data$western_year[order(expo_data$western_year)],
    "年)"
)
expo_data$label <- factor(
    label,
    levels = label,
    ordered = TRUE
)

# データフレームの表示
print(expo_data)

# 平均年収のスケールを調整する
expo_data$give_mean_10k <- expo_data$give_mean / 10000

# 平均年収と入場料のスケールを合わせる
entrance_fee_min <- min(expo_data$entrance_fee)
entrance_fee_max <- max(expo_data$entrance_fee)
give_mean_min <- min(expo_data$give_mean_10k)
give_mean_max <- max(expo_data$give_mean_10k)
scaler <- (entrance_fee_max - entrance_fee_min) /
    (give_mean_max - give_mean_min)

# グラフの作成
graph <- ggplot(data = expo_data, aes(x = label)) +
    geom_line(
        aes(y = entrance_fee, group = 1, colour = "入場料 (1円単位)"),
        linewidth = 1.2
    ) +
    geom_line(
        aes(
            y = give_mean_10k * scaler,
            group = 1,
            colour = "平均所得 (1万円単位)"
        ),
        linewidth = 1.2
    ) +
    scale_y_continuous(
        expand = c(0, 0),
        sec.axis = sec_axis(
            transform = ~ .x / scaler,
            breaks = seq(from = give_mean_min, to = give_mean_max, by = 50),
            name = "\n日本国民の平均所得 (万円)\n"
        )
    ) +
    scale_x_discrete(expand = c(0.07, 0.07)) +
    scale_color_manual(
        name = "凡例",
        values = c("入場料 (1円単位)" = "blue", "平均所得 (1万円単位)" = "red")
    ) +
    labs(
        x = "\n万博名 (開催年)\n",
        y = "\n万国博覧会の大人入場料 (円) \n",
        title = "\n万博の入場料と平均所得",
        subtitle = "日本で開催された万国博覧会の大人の入場料と日本国民の平均所得(万円)との関係"
    ) +
    theme(
        # 基本フォントサイズ
        text = element_text(size = 40),
        # X軸ラベルの回転
        axis.text.x = element_text(angle = 30, hjust = 1)
    )

# 保存
ggsave("sample.png", plot = graph, width = 11, height = 7, dpi = 300)
