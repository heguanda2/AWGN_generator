% This program generates the 64-bit uniform random sequence (10000) 
% They are stored in a .DAT to be put into the FPGA's input MEM. 

x_in =ones(10000,64);
factor = zeros(1,64);
x_in_num = ones(1,10000);
for j = 1:64
    factor(j) = 2^-j;
end
for i = 1:10000
    x1 = randi([0 1],1,64);
    x_in(i,:) = x1;      % to be stored in the input MEM
    x_in_num(i) = (dot(factor, x1)); %decimal equilvalent 
end



q = norminv(x_in_num);
plot(q);
title('sample gaussian');
[h,p] = kstest(q);
if h == 0
    display('test pass, the random signal is uniform distributed');

else
    display('test failed, the random signal is not uniform distributed');
end
display(h);
display(p);

%%%% Remove the comments when want to try new PRBS input

%save('unif_input.dat','-ascii','x_in');
%m = load('unif_input.dat','-ascii','x_in') ;

%f = fopen('unif_in.txt','wt');
%for i = 1:10000
% q = num2str(m(i,:));
% q = q(find(~isspace(q)));
% fprintf(f,[q,'\n']);
%end
%fclose(f);    