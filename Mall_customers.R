#### Projekt: Przeprowadzenie analizy skupień na zbiorze mall_customers

# Czyszczenie pamieci srodowiska
rm(list=ls())
graphics.off()

mall_data <- read.csv("Mall_Customers.csv", header = TRUE, row.names = 1)
View(mall_data)


# Potrzebne biblioteki
library(clusterSim)
library(cluster)
library(fossil)
library(factoextra)
library(ggplot2)
library(NbClust)

# Wykresy do zbadania rozkładu danych
boxplot(mall_data[,c("Age", "Annual.Income..k..", "Spending.Score..1.100.")],
        main = "Boxplot - Mall Customers",
        col = c("lightblue", "lightgreen", "lightyellow"))


par(mfrow = c(1,3))

# Age
hist(mall_data$Age, 
     main = "Age Distribution", 
     xlab = "Age",
     col = "lightblue",
     probability = TRUE)  # important! switches y-axis to density
lines(density(mall_data$Age), col = "red", lwd = 2)

# Annual Income
hist(mall_data$Annual.Income..k.., 
     main = "Income Distribution", 
     xlab = "Annual Income (k$)",
     col = "lightgreen",
     probability = TRUE)
lines(density(mall_data$Annual.Income..k..), col = "red", lwd = 2)

# Spending Score
hist(mall_data$Spending.Score..1.100., 
     main = "Spending Score Distribution", 
     xlab = "Spending Score",
     col = "lightyellow",
     probability = TRUE)
lines(density(mall_data$Spending.Score..1.100.), col = "red", lwd = 2)

par(mfrow = c(1,1))

# Data normalization

mall_data_z <- scale(mall_data[2:4])
head(mall_data_z)

# Wyswietlanie metod 
set.seed(42)

# WSS - Elbow Methhod
fviz_nbclust(mall_data_z, kmeans, method = "wss") +
  labs(title = "Elbow Method", 
       x = "Number of clusters", 
       y = "WSS")

# Silhouette 
fviz_nbclust(mall_data_z, kmeans, method = "silhouette") +
  labs(title = "Silhouette Method",
       x = "Number of clusters",
       y = "Silhouette score")

# Gap Statistic
fviz_nbclust(mall_data_z, kmeans, method = "gap_stat", nboot = 100) +
  labs(title = "Gap Statistic",
       x = "Number of clusters",
       y = "Gap statistic")

# Znajac optmalna liczbe clustrow k==6 uzywamy metody k-means 

library(factoextra)

# Run k-means with k=6
set.seed(42)
km_mall <- kmeans(mall_data_z, centers = 6, nstart = 25)

# rozmiar clusterow
km_mall$size

# centroidy
km_mall$centers

# Wizualizacja
fviz_cluster(km_mall, 
             data = mall_data_z,
             ellipse.type = "convex",
             palette = "jco",
             ggtheme = theme_minimal(),
             main = "Mall Customer Segments - K-Means (k=6)")


mall_data$cluster <- km_mall$cluster

# avg profil clustra przed standaryzacja
aggregate(mall_data, by = list(Cluster = mall_data$cluster), mean)


# Testowanie z metoda warda.d2 

d <- dist(mall_data_z,method = 'euclidean')

ward_mall <- hclust(d,method = "ward.D2")

fviz_dend(ward_mall, 
          k = 6,
          show_labels = FALSE,
          rect = TRUE,
          main = "Mall Customers - Ward's Method Dendrogram (k=6)",
          ylab = "Distance")


ward_clusters <- cutree(ward_mall, k = 6)

fviz_cluster(list(data = mall_data_z, cluster = ward_clusters),
             ellipse.type = "convex",
             palette = "jco",
             ggtheme = theme_minimal(),
             main = "Mall Customers - Ward's Method (k=6)")

adj.rand.index(km_mall$cluster, ward_clusters)

# Profile clustrow
mall_data$ward_cluster <- ward_clusters
aggregate(mall_data[,2:4], by = list(Cluster = mall_data$ward_cluster), mean)








