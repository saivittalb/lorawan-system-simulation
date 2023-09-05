 %This program simulates BER of GFSK in AWGN channel%
 close all; clc;
 num_bit=12;                              %Signal length 
 max_run=10000;                           %Maximum number of iterations for a single SNR
 Eb=1;                                    %Bit energy
 SNRdB=0:1:10;                            %Signal to Noise Ratio (in dB)
 SNR=10.^(SNRdB/10);                      
 hand=waitbar(0,'Please Wait....');
 BER_sim=zeros(length(SNR));
 for count=1:length(SNR)                  %Beginning of loop for different SNR
     avgError=0;
     No=Eb/SNR(count);                    %Calculate noise power from SNR
     
     for run_time=1:max_run               %Beginning of loop for different runs
         waitbar((((count-1)*max_run)+run_time-1)/(length(SNRdB)*max_run));
         Error=0;
         
         data=randi(1,num_bit);            %Generate binary data source
         encode_data=golaycodec(data);     %Encode using Golay
         s=data+1i*(~data);                %Baseband GFSK modulation
         
         NI=sqrt(No/2)*randn(1,num_bit);
         NQ=sqrt(No/2)*randn(1,num_bit);
         N=NI+1i*NQ;                       %Generate complex AWGN
         err=zeros(1,23);
         err(ceil(23*rand(1,3)))=1;        %Random errors
         decode_data=xor(encode_data,err); %Transmission error
         
         Y=s+N;                            %Received Signal
         
         Z=zeros(num_bit);
         [data,err]=golaycodec(decode_data); %Decode using Golay
         for k=1:num_bit                  %Decision device taking hard decision and deciding error
             Z(k)=real(Y(k))-imag(Y(k));
             if ((Z(k)>0 && data(k)==0)||(Z(k)<0 && data(k)==1))
                 Error=Error+1;
             end
         end
        
         Error=Error/num_bit;             %Calculate error/bit
         avgError=avgError+Error;         %Calculate error/bit for different runs        
     end                                  %Termination of loop for different runs
     BER_sim(count)=avgError/max_run;     %Calculate BER for a particular SNR
 end                                      %Termination of loop for different SNR 
 BER_th=(1/2)*erfc(sqrt(SNR/2));          %Calculate analytical BER
 close(hand);
 
 semilogy(SNRdB,BER_th,'k','linewidth',1);              %Plot BER
 grid on, hold on;
 semilogy(SNRdB,BER_sim,'k*');
 legend('Theoretical','Simulation');
 title('BER vs SNR for LoRaWAN with Golay (GFSK)');
 xlabel('SNR (dB)');
 ylabel('BER');
 axis([min(SNRdB) max(SNRdB) 10^(-5) 1]);
 hold off