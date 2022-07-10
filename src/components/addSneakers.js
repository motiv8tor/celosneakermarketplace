import React from 'react';
import { useState } from "react";

export const AddSneaker = (props) => {

const [image, setImage] = useState('');
const [brand, setBrand] = useState('');
const [description, setDescription] = useState('');
const [price, setPrice] = useState('');
const [availablesneakers, setAvailableSneakers] = useState(0);


  return <div>
      <form>
  <div class="form-row">
    
      <input type="text" class="form-control" value={image}
           onChange={(e) => setImage(e.target.value)} placeholder="image"/>

      <input type="text" class="form-control" value={brand}
           onChange={(e) => setBrand(e.target.value)} placeholder="brand name"/>
           
      <input type="text" class="form-control mt-2" value={description}
           onChange={(e) => setDescription(e.target.value)} placeholder="description"/>

      <input type="text" class="form-control mt-2" value={price}
           onChange={(e) => setPrice(e.target.value)} placeholder="price"/>

      <input type="text" class="form-control" value={availablesneakers}
           onChange={(e) => setAvailableSneakers(e.target.value)} placeholder="sneakers available"/>

      <button type="button" onClick={()=>props.addSneaker(image, brand, description, price, availablesneakers)} class="btn btn-dark mt-2">Add Sneaker</button>
  </div>
</form>
  </div>;
};
