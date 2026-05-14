{ ... }:

{
  users.users.woliver99 = {
    isNormalUser = true;
    description = "Oliver Wuthrich-Giroux";

    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
      "dialout"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDuwRatBid7XOw9Q5tVSAQ5bxALEKSBHOr1tdkOUMiYGci2E+Iym2Hyf0DOGkSRRHuiaUVoTYOki56/k7pRkTIh21W9yOORjfxbMfpoRxHhtjdxpMLu+srXKsOrmH+wKo+blE6/RHRUzG8bAsM2mG/0nHynIegwqwaznkbctwV4IeWPkZ1RYCbCxmJyIKzRYc08DVaX2oa5L16eDxrVod1nmJ7DE5OD7HGNNCYE9st9eJDlO/ds7S67rw+IhQ8Xlqmmrysjpa1KWU3x03QNcKIW13u2hag/05WR1IrIJSDak6ciRcQut5ntjJVnrQT6ZooBZ4zeCbDaQF7qS2RKm8OpgNRRqm3qUj8ork3Gx71VCGx2yStcXupD4NgQ0bk0XmsbeGWr+Z9tyF3cH8tXI1NAab/ja0aT5QNUNM4+bEOByUSSxKs4SpBc8L+ZhDcgcD3W6JoTDE1QKTxwZVbwIel+PVsKVSxE5bFgeRjtMuhvxEx7lidpDtLqrxDuQ6tGAoPks6fHECKkO4j11MadbjymY+0EbXle72c4nRSv1WZ+eGvG+kLsBAFlanbGZie8E7rxpl4edw4S2N+Bn7kSr7uWpdjG1ri+oVKNMYobUMtLJte/tJZ2Veglp12D4TBsiO7IUxuZ0i3fxK2uTxsf3gE2ZN+4kjOqpal7vt5p7HPOkw== olive@Oliver-Super-Fast-Laptop"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuZv1PB2vvR4yAIMUkWltu8z1q0BCaoF3pUrYp0YkxGzvf72bdOG8z4iRG23hLPf1vUJkNTJn8euBgnErdoANu2glU/EkV2cVXnBFNztN3LrXveJwS1Or8m21FlhWesqXSm0saQaBFnNh7SZw2n9IHB6+w6yCE+FSgrG/gmY/EbtkxD2em06uL0wn8uTVjCtWEVP3dYqQLfVSrkL0L6tLSM0fu+p6wwJsgWJIgelf8OjrIXHmku4uDpYmc5xyBkjw8rGahYwX9ls72d5LGTLdDw0rJkTkXILn4KP1YcyAgEfIAnWZ9kuzv1PK2PQ+kQklRLowchvj3UYDgkrrMTtxtKQ4WrikG43r/raWD7TOkuCbxLGe5njJ35UNUAa718lXKbRXnwZbPLQoEkZlckitVKTeKT3Rs/wJu69jDPHrRMTnzy6dm8YvcIZarrKpIHN4LGs2AKHTK4oeCp4iZ7HXLAX6ddmFmuD9B8vgl/5DbiRiJ9+HilBaLIrXXnDCJw260Kecm1pdWfmafxkAgfMKknBZ7Vn6zxAeggwGyVDaTnR724BrxE6DJScQHI/mJGvRV5vqJuLdjYVLaKPlee09/qPDlpKYF+kF2NnZXgjuKTuL3PXhgslAJdaRZzB16SJCh+68ssgHAO/k9Pn/6GqAFZz77H0Ct8xwcGuEbmv8JeQ== oliver@1QRS403"
    ];
  };

  programs.git.config.user = {
    name = "woliver99";
    email = "oliver@maplenetwork.ca";
  };
}
