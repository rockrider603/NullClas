const hre=require("hardhat");
async function main(){
    const CrowdTank= await hre.ethers.getContractFactory("crowdtank");
    const crowdtank=await CrowdTank.deploy();
    // await crowdtank.getDeployedCode();
    console.log("CrowdTank deployed to:" + crowdtank.address);

}
main()
.then(()=> process.exit(0));
