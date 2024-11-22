// src/screens/HomeScreen.js
import React from 'react';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';
import useFetch from '../hooks/useFetch';

function HomeScreen() {
  const { data, loading, error } = useFetch('/home');

  if (loading) return <ActivityIndicator size="large" color="#0000ff" />;
  if (error) return <Text>Error: {error}</Text>;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Home Data</Text>
      <Text>{JSON.stringify(data)}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
  },
});

export default HomeScreen;
