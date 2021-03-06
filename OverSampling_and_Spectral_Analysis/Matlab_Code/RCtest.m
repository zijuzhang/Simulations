 [num,den] = rcosine(1,8,'default',0.22)
  [ h ] = RaisedCosine( 0.388, 8 )/8
  im = ...
      [   -0.0000
   -0.0003
   -0.0007
   -0.0010
   -0.0013
   -0.0015
   -0.0014
   -0.0009
    0.0000
    0.0013
    0.0029
    0.0045
    0.0058
    0.0063
    0.0056
    0.0036
   -0.0000
   -0.0048
   -0.0101
   -0.0153
   -0.0190
   -0.0203
   -0.0180
   -0.0113
    0.0000
    0.0156
    0.0347
    0.0558
    0.0770
    0.0963
    0.1118
    0.1218
    0.1253
    0.1218
    0.1118
    0.0963
    0.0770
    0.0558
    0.0347
    0.0156
    0.0000
   -0.0113
   -0.0180
   -0.0203
   -0.0190
   -0.0153
   -0.0101
   -0.0048
   -0.0000
    0.0036
    0.0056
    0.0063
    0.0058
    0.0045
    0.0029
    0.0013
    0.0000
   -0.0009
   -0.0014
   -0.0015
   -0.0013
   -0.0010
   -0.0007
   -0.0003
   -0.0000
];
Fs = 8;
figure
n = length(h);
t = (-(n-1)/2:(n-1)/2)/Fs;
plot(t,h);

hold on
n = length(im);
t = (-(n-1)/2:(n-1)/2)/Fs;
plot(t,im,':r')