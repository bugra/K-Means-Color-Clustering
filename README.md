# Introduction
Another implementation of K-means algorithm for color quantization in the images.  This one is substantially commented, so some may find it useful.  
However, it is slow(even for Matlab) due to inverse mapping. It does not store the cluster assignment of the pixels but calculates the distance from the center of the cluster in every iteration. Therefore, it is not computation efficient.  
It does not need additional space, though. As the inverse mapping is computed on the fly, there is no need for storing the clustered pixels.  
`read_color_raw.m`  reads `.raw` color images. `readraw` reads grayscale `.raw` in images, which are both used in `k_means_Color_Clustering.m`. `mean_square_error.m` computes the euclidean distance between two images by pixel values.   

## Results
__K = 2__  

![Alt text][2]
__K = 3__  

![Alt text][3]
__K = 4__  

![Alt text][4]
__K = 5__  

![Alt text][5]
__K = 6__  

![Alt text][6]
__K = 7__  

![Alt text][7]
__K = 8__  

![Alt text][8]
__K = 9__  

![Alt text][9]
__K = 10__  

![Alt text][10]

[2]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger12.png "K=2"
[3]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger13.png "K=3"
[4]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger14.png "K=4"
[5]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger15.png "K=5"
[6]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger16.png "K=6"
[7]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger17.png "K=7"
[8]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger18.png "K=8"
[9]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger19.png "K=9"
[10]: https://raw.github.com/bugra/K-Means-Color-Clustering/master/result/tiger110.png "K=10"
