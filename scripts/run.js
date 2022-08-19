main= async()=> {
    const [owner,user]= await hre.ethers.getSigners();
    const stuckfactory=await hre.ethers.getContractFactory('StuckMaxFactory');
    const factory= await stuckfactory.deploy();
    await factory.deployed;
    console.log('factory deployed at: ', factory.address);
    console.log('owner is: ', owner.address)

    let init;
    let value='0.05';
    let newValue= hre.ethers.utils.parseEther(value)
    init= await factory.generateChild('testMovie',newValue, 5);
    let txreceipt= await init.wait();
    const Events= txreceipt.events.find(event=>event.event==='ChildCreated')
    const [name,addr,uname]=Events.args;
    console.log('address: ',addr, '\n uname: ', uname);

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