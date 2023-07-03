using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.SqlClient;
namespace ConsoleApp1
{
    class Program
    {
        public static string ConnectionString = @"Server=ASUS\SAPHIR;Database=Apteka;User Id=apteka;Password=123456;"; 
        
         static void Main(string[] args)
        {
              using (SqlConnection cn = new SqlConnection(ConnectionString)) {
                cn.Open();
                //create new drugstore
                SqlCommand addDrugstore = new SqlCommand("AddDrugstory", cn);
                addDrugstore.CommandType = CommandType.StoredProcedure;
                SqlParameter addDrugstoreName = new SqlParameter("@name", "Аптека Здоровье");
                addDrugstoreName.SqlDbType = SqlDbType.NVarChar;
                addDrugstore.Parameters.Add(addDrugstoreName);
                SqlParameter addDrugstoreAdress = new SqlParameter("@adress", "ул. Каховка д.10");
                addDrugstoreAdress.SqlDbType = SqlDbType.NVarChar;
                addDrugstore.Parameters.Add(addDrugstoreAdress);
                SqlParameter addDrugstorePhone = new SqlParameter("@telephone", "499 1211153");
                addDrugstorePhone.SqlDbType = SqlDbType.NVarChar;
                addDrugstore.Parameters.Add(addDrugstorePhone);
                addDrugstore.Parameters.Add("@drugstory_id", SqlDbType.Int).Direction = ParameterDirection.Output;

                addDrugstore.ExecuteNonQuery();
                

                int drugstoreID = Convert.ToInt32(addDrugstore.Parameters["@drugstory_id"].Value);
                
                //add new store
                SqlCommand addStore = new SqlCommand("StoresAdd", cn);
                addStore.CommandType = CommandType.StoredProcedure;
                SqlParameter drugStoreIdParameter = new SqlParameter("@drugstore_id", SqlDbType.Int);
                drugStoreIdParameter.Value = drugstoreID;
                addStore.Parameters.Add(drugStoreIdParameter);
                SqlParameter storeNameParameter = new SqlParameter("@name", SqlDbType.NVarChar);
                storeNameParameter.Value = "Склад № 1";
                addStore.Parameters.Add(storeNameParameter);
                addStore.Parameters.Add("@store_id", SqlDbType.Int).Direction = ParameterDirection.Output;
                addStore.ExecuteNonQuery();
                int store_id = Convert.ToInt32(addStore.Parameters["@store_id"].Value);

                //add new product
                SqlCommand addMerchandises = new SqlCommand("merchandisesAdd", cn);
                addMerchandises.CommandType = CommandType.StoredProcedure;
                SqlParameter merchandisesName = new SqlParameter("@name", SqlDbType.NVarChar);
                merchandisesName.Value = "Супрастин";
                addMerchandises.Parameters.Add(merchandisesName);
                addMerchandises.Parameters.Add("@merchandise_id", SqlDbType.Int).Direction = ParameterDirection.Output;
                addMerchandises.ExecuteNonQuery();
                int merchandise_id = Convert.ToInt32(addMerchandises.Parameters["@merchandise_id"].Value);

                //add new shipment
                SqlCommand addShipmentCmd = new SqlCommand("shipmentsAdd", cn);
                addShipmentCmd.CommandType = CommandType.StoredProcedure;
                addShipmentCmd.Parameters.Add("@merchandise_id", SqlDbType.Int).Value = merchandise_id;
                addShipmentCmd.Parameters.Add("@store_id", SqlDbType.Int).Value = store_id;
                addShipmentCmd.Parameters.Add("@quantity", SqlDbType.Int).Value = 10;
                addShipmentCmd.Parameters.Add("@shipment_id", SqlDbType.Int).Direction = ParameterDirection.Output;
                addShipmentCmd.ExecuteNonQuery();
                int shipment_id = Convert.ToInt32(addShipmentCmd.Parameters["@shipment_id"].Value);
                //delete  shipment
                SqlCommand deleteShipmentCmd = new SqlCommand("ShipmentDelete", cn);
                deleteShipmentCmd.CommandType = CommandType.StoredProcedure;
                deleteShipmentCmd.Parameters.Add("@shipment_id", SqlDbType.Int).Value = shipment_id;
                deleteShipmentCmd.ExecuteNonQuery();

                //delete product
                SqlCommand deleteMerchandises = new SqlCommand("MerchandisesDelete", cn);
                deleteMerchandises.CommandType = CommandType.StoredProcedure;
                SqlParameter merchandiseIdParameter = new SqlParameter("@merchandise_id", SqlDbType.Int);
                merchandiseIdParameter.Value = merchandise_id;
                deleteMerchandises.Parameters.Add(merchandiseIdParameter);
                deleteMerchandises.ExecuteNonQuery();

                //delete store
                SqlCommand deleteStore = new SqlCommand("StoresDelete", cn);
                deleteStore.CommandType = CommandType.StoredProcedure;
                SqlParameter deleteStoreStoreId = new SqlParameter("@store_id", SqlDbType.Int);
                deleteStoreStoreId.Value = store_id;
                deleteStore.Parameters.Add(deleteStoreStoreId);
                deleteStore.ExecuteNonQuery();

                //delete drugstore
                SqlCommand deleteDrugstore = new SqlCommand("DrugstoreDelete", cn);
                deleteDrugstore.CommandType = CommandType.StoredProcedure;
                SqlParameter drugstoreIDParameter = new SqlParameter("@drugstore_id", SqlDbType.Int);
                drugstoreIDParameter.Value = drugstoreID;
                deleteDrugstore.Parameters.Add(drugstoreIDParameter);
                deleteDrugstore.ExecuteNonQuery();
                cn.Close();
            }
                Console.ReadLine();
        }

        
    }
}
