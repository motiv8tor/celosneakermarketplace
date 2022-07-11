import React from 'react';
import { useState } from "react";

export const Sneakers = (props) => {

  const [buyeraddress, setBuyerAddress] = useState('');
  const [feedback, setFeedback] = useState('');


  return <div className="card-container">

{props.sneakers.map((s) =>(
    <div class="card">
    <img class="card-img-top" src={s.image} alt="Card image cap" />
    <div class="card-body">
      <h5 class="card-title">Brand: {s.brand}</h5>
      <h5 class="card-title">Price: {s.price  / 1000000000000000000}cUSD</h5>
      <h5 class="card-title">{s.availableSneakers > 0 ? `Sneakers Available: ${s.availableSneakers}` : `Sold Out`} </h5>
      <h5 class="card-title">Sneakers Returned: {s.sneakersReturned} </h5>
      <h5 class="card-title">Sneakers Sold: {s.sneakersSold} </h5>
      <p class="card-text">Description: {s.description}</p>
    

      { props.walletAddress !== s.owner && s.availableSneakers > 0 &&(
      <button type="button" onClick={()=>props.buySneaker(s.index)} class="btn btn-dark mt-2">Buy Sneaker</button>
      )}

    { props.walletAddress !== s.owner && (
     <form>
  <div class="form-r">
      <input type="text" class="form-control mt-4" value={feedback}
           onChange={(e) => setFeedback(e.target.value)} placeholder="enter feedback"/>
      <button type="button" onClick={()=>props.returnSneaker(s.index, feedback)} class="btn btn-dark mt-2">Return</button>
      
  </div>
</form>
)}



{ props.walletAddress === s.owner && (
     <form>
  <div class="form-r">
      <input type="text" class="form-control mt-4" value={buyeraddress}
           onChange={(e) => setBuyerAddress(e.target.value)} placeholder="buyer address"/>
      <button type="button" onClick={()=>props.repayBuyer(s.index, buyeraddress)} class="btn btn-dark mt-2">Repay buyer</button>
      
  </div>
</form>
)}


      { props.walletAddress === s.owner &&(
                    <button
                      type="submit"
                      onClick={() => props.deleteSneakerlisting(s.index)}
                      className="btn btn-dark m-3"
                    >
                      Delete Sneaker
                    </button>
                       )}


{ props.walletAddress === s.owner &&(
        s.feedbacks.map((f) =>(
      <p class="card-text mt-2" key={f.index}>feedback {f.Id}. {f.feedbackDescription}<br /> Address: {f.owner}</p>
      
         ))
      )}
    </div>
  </div>
  ))}

</div>
};
