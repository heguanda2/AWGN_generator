% This program compares the matlab's output and FPGA's output
a = load('matlab_result.dat','-ascii','awgn_out');

f = fopen('RTL_output.txt','r');
q = zeros(10000,16);
formatSpec = '%s';
text = fscanf(f,formatSpec);
fclose(f);
factor = zeros(16,1);
for i = 1:16
   if i == 1
       factor(i) = -2^(3-i);
   else
       factor(i) = 2^(3-i);
   end
end
final = zeros(10000,1);
for i = 5:10000
    for j = 1:16
        q(i,j) = str2num(text(16*(i-1)+j));
    end
    final(i) = dot(q(i,:),factor);
end

%final = final ./ sqrt(mean(final.^2));
%final = final - mean(final);
[h,p] = kstest(final);
display(h);
display(p);

if(h == 0)
    display('FPGA test sucessful!');
else
    display('FPGA test failed!');
end



spec1 = fftshift(fft(a))/length(a);
spec2 = fftshift(fft(final))/length(final);

m = times(spec1, conj(transpose(spec2)));
q = ifft(ifftshift(m));
plot(abs(q));

[boring,index111] = max(abs(q));

%plot(circshift(a,[0,-4]));
plot(a(2:10000));
hold on;
plot(final(5:10000),'rs');
legend('Matlab result','FPGA result');
xlim([1 100]);
hold off;



