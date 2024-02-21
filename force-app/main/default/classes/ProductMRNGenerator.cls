global virtual class ProductMRNGenerator {
    
    global virtual String generateMRN(String accountId) {
        String mrn = '';
        if(String.isNotBlank(accountId)){
            Integer randomNum = Math.mod(Math.abs(Crypto.getRandomInteger()), 100);
            mrn = 'EXR'+accountId.substring(accountId.length() - 7)+randomNum;
        }     
        return mrn;
    }
    
}