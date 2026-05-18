rm(list=ls())
graphics.off()

library(clusterSim)
library(cluster)
library(fossil)
library(factoextra)
library(ggplot2)
library(NbClust)

setwd("~/Documents/Karol/Studia Uek/Nienadzorowane uczenie statystyczne/Projekt 2 ")

data <- read.csv("Projekt_2_dane_z_2023_roku.csv", header = TRUE, sep = ";",dec = ",",row.names =1)

# Normalizacja za pomocą Standaryzacja
data_z <- data
data_z[1:8] <- scale(data_z[1:8])

# Normlaizacja za pomoca unitaryzacji zerowanej 
data_u <- data 
data_u <- data.Normalization(data_u[1:8], type="n4")

# Normalizacja z wykorzystaniem standaryzacji pozycyjnej 
data_p <- data 
data_p <- data.Normalization(data_p[1:8], type="n2")

#parameter k.max jest to maksymalna ilosc grupy ktora rozwazamy, podana w poleceniu

# Metoda warda 
fviz_nbclust(data_z[, 1:8],FUNcluster = hcut,  
             method = "gap_stat",
             hc_method = "ward.D2",
             hc_metric = "manhattan", 
             k.max = 15) +
  labs(x = "Liczba grup", y = "Metoda warda") +
  geom_point() +
  ggtitle(expression('Metoda warda z użyciem indesku gapa'))

#Metoda k-srednich 
fviz_nbclust(data_z[, 1:8], kmeans, method = "wss", k.max = 15,nstart = 50) +
  labs(x = "Liczba grup", y = "WSS") +
  geom_point() +
  ggtitle(expression('Metoda'~italic(k)~'-średnich - Metoda łokcia'))

# Metoda k-medoidow
fviz_nbclust(data_z[, 1:8], 
             FUNcluster = pam,       
             method = "gap_stat", 
             k.max = 15) + 
  labs(x = "Liczba grup", y = "Statystyka Gap") +
  geom_point() +
  ggtitle("Metoda k-medoidów (PAM) z użyciem indeksu Gap")

# Metoda dendrytowa
fviz_nbclust(data_z[, 1:8], 
             FUNcluster = hcut, 
             method = "gap_stat",
             hc_method = "single",    
             hc_metric = "euclidean", 
             k.max = 15) +
  labs(x = "Liczba grup", y = "Statystyka Gap") +
  geom_point() +
  ggtitle("Metoda dendrytowa (Single Linkage) - Indeks Gap")
#Grupa 1 (lewa): Największe metropolie (Warszawa, Kraków, Wrocław, Poznań). Są wyraźnie oddzielone od reszty wysokim "cięciem" (oś Height).
#Grupa 2 i 4: Średnie i mniejsze miasta, które mają podobną charakterystykę, ale tworzą dwa osobne pod-drzewa.
#Grupa 3 (wąska ramka): Widzisz tę bardzo wąską ramkę w środku? To jest właśnie powód Twoich problemów z metodą dendrytową. To prawdopodobnie jedno lub dwa miasta (np. Jastrzębie-Zdrój, Skierniewice), które bardzo różnią się od reszty.

#Dodatkowy test 
NbClust(data_z[, 1:8],distance = "manhattan", min.nc = 2, method = "ward.D2",max.nc = 15,index = "all")



#Badanie stabilności podziału na optymalną liczbę k grup 
#Standaryzacja(n1), odlegosc manhatan(d1), metoda ward, u - jest liczba grup :  poniżej 0,2: podział niestabilny,◦ 0,2 – 0,4: podział mało stabilny,◦ 0,4 – 0,6: podział relatywnie stabilny,◦ 0,6 – 0,8: podział stabilny,◦ 0,8 – 1,0: podział wysoce stabiln
wynik_randa <- replication.Mod(
  data_z, 
  u = 4,                 
  normalization = "n1",  
  distance = "d1",       
  method = "ward",       
  S = 20                 
)
wynik_randa

View(data_z)

#Rysowanie denodgramu
dist_z <- dist(data_z, method = "manhattan")
ward_z <- hclust(dist_z, method = "ward.D2")
klasy <- cutree(ward_z, k= 4)

plot(ward_z, cex = 0.6, main = "Dendrogram miast na prawach powiatu")
rect.hclust(ward_z, k = 4, border = "red") 

#Charakterystyka
charakterystyka <- cluster.Description(data_z, klasy)
print(charakterystyka[,,1]) 

#Boxplot
boxplot(data_z[,1] ~ klasy, 
        main = "Zróżnicowanie zmiennej X1 w grupach",
        xlab = "Numer Grupy", 
        ylab = "Znormalizowana wartość X1",
        col = "lightblue")
#Grupa 1: Ma najniższe wartości zmiennej X1 (poniżej średniej, ok. -0.8). Rozstęp jest dość wąski, ale występuje jeden outlier (kropka nad wąsem), co może mylić metodę dendrytową.
#Grupa 2: Wartości oscylują wokół średniej (blisko 0). To grupa o umiarkowanym zróżnicowaniu.
#Grupa 3: Wyraźnie wyższe wartości X1 (średnio ok. 1.7). To grupa o największym rozproszeniu wewnętrznym (najdłuższe "wąsy" i największe pudełko).
#Grupa 4 (po prawej): To jest klucz do zagadki. Widzimy tu tylko pojedynczą, grubą linię na bardzo niskim poziomie.


#Wybranie grup
View(data_z)
dist_z <- dist(data_z, method = "manhattan")
ward_z <- hclust(dist_z, method = "ward.D2")
klasy <- cutree(ward_z, k= 4)
View(klasy)

klasy_df <- data.frame(
  miasto = names(klasy),
  klaster = as.integer(klasy)
)

subset(klasy_df, klaster == 4)











