main= async()=> {
    const [owner,user]= await hre.ethers.getSigners();
    const stuckfactory=await hre.ethers.getContractFactory('stuckMaxFactory');
    const factory= await stuckfactory.deploy();
    await factory.deployed;
    console.log('factory deploye at: ', factory.address);
    console.log('owner is: ', owner.address)

    let init;
    let value='0.05';
    let newValue= hre.ethers.utils.parseEther(value)
    init= await factory.generateChild('testMovie',newValue, 5);
    await init.wait();
    console.log(init);

    let getChild;
    getChild= await factory.viewAllChild();
    console.log('all child',getChild);

    let newOwner;
    newOwner= await factory.changeStuckMax(user.address);
    await newOwner.wait();
    console.log(await factory.stuckmax());

};

const runMain=async()=>
{
    try{
        await main();
        process.exit(0);
    }catch(error){
        console.log(error);
        process.exit(1); 
    }
    
};
runMain();