library(ggplot2)
suppressMessages({
    library(tidyverse)
    library(showtext)
    showtext_auto()
})

# データを読み込む
expo_data <- read.csv("../data/data.csv")

# ラベル順
label <- paste0(
    expo_data$name[order(expo_data$western_year)],
    " (",
    expo_data$western_year[order(expo_data$western_year)],
    "年)"
)
expo_data$label <- factor(label, levels = label, ordered = TRUE)

# スケーリング準備
expo_data$give_mean_10k <- expo_data$give_mean / 10000
entrance_fee_min <- min(expo_data$entrance_fee)
entrance_fee_max <- max(expo_data$entrance_fee)
give_mean_min <- min(expo_data$give_mean_10k)
give_mean_max <- max(expo_data$give_mean_10k)
scaler <- (entrance_fee_max - entrance_fee_min) /
    (give_mean_max - give_mean_min)
expo_data$scaled_income <- expo_data$give_mean_10k * scaler

# 縦長のdata.frameに変換
expo_data <- expo_data %>%
    select(label, entrance_fee, scaled_income) %>%
    pivot_longer(
        cols = c("entrance_fee", "scaled_income"),
        names_to = "type",
        values_to = "value"
    ) %>%
    mutate(
        type = recode(
            type,
            "entrance_fee" = "入場料 (1円単位)",
            "scaled_income" = "平均所得 (1万円単位)"
        )
    )

# グラフ
graph <- ggplot(data = expo_data, aes(x = label, y = value, fill = type)) +
    geom_col(position = "dodge", width = 0.6) +
    scale_y_continuous(
        expand = c(0, 0),
        sec.axis = sec_axis(
            transform = ~ . / scaler,
            breaks = seq(from = give_mean_min, to = give_mean_max, by = 50),
            name = "\n日本国民の平均所得 (万円)\n"
        )
    ) +
    scale_x_discrete(expand = c(0.07, 0.07)) +
    scale_fill_manual(
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
        text = element_text(size = 40),
        axis.text.x = element_text(angle = 30, hjust = 1)
    )


# 保存
ggsave("sample.png", plot = graph, width = 11, height = 7, dpi = 300)
